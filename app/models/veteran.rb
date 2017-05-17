class Veteran < ActiveRecord::Base
  include PgSearch

  belongs_to :user
  has_many :affiliations, dependent: :destroy
  has_many :awards, dependent: :destroy
  has_many :experiences, dependent: :destroy, inverse_of: :veteran
  has_many :locations, dependent: :destroy
  has_many :references, dependent: :destroy
  has_many :favorite_veterans, dependent: :destroy
  has_many :favorited_by, through: :favorite_veterans, source: :employer
  has_and_belongs_to_many :skills, join_table: :veteran_skills

  validates_presence_of :name, message: "cannot be blank or employers cannot contact you"
  validates_presence_of :email, message: "cannot be blank or employers cannot contact you"
  validates_length_of :name, maximum: 255, message: "cannot exceed 255 characters"
  validates_length_of :email, maximum: 255, message: "cannot exceed 255 characters"

  accepts_nested_attributes_for :affiliations, allow_destroy: true, reject_if: proc {|attributes| attributes.collect{|k,v| v.blank? || k == '_destroy' }.all? }
  accepts_nested_attributes_for :awards, allow_destroy: true, reject_if: proc {|attributes| attributes.collect{|k,v| v.blank? || k == '_destroy'}.all? }
  accepts_nested_attributes_for :locations, allow_destroy: true, reject_if: proc {|attributes| attributes.collect{|k,v| v.blank? || k == '_destroy' || k == 'location_type'}.all? }
  accepts_nested_attributes_for :experiences, allow_destroy: true, reject_if: proc {|attributes| attributes.reject{|k,v| k == "experience_type" || k == '_destroy'}.collect{|k,v| v.blank?}.all? }
  accepts_nested_attributes_for :references, allow_destroy: true, reject_if: proc {|attributes| attributes.collect{|k,v| v.blank? || k == '_destroy'}.all? }

  serialize :desiredPosition, Array
  serialize :status_categories, Array

  pg_search_scope :keyword_search_all,
                  against:  :searchable_summary,
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable_summary',
                      prefix: true
                    }
                  }
  pg_search_scope :keyword_search_any,
                  against:  :searchable_summary,
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable_summary',
                      any_word: true,
                      prefix: true
                    }
                  }

  STATUS_CATEGORIES = ["Service-Connected Disabled Veteran", "Service-Connected Disabled Veteran (10%)", "Service-Connected Disabled Veteran (30%)", "Veteran"]

  after_save :fill_search_summary

  class << self

    def purge (older_than = 1.day.ago)
      where('user_id IS NULL AND updated_at < ?', older_than).destroy_all
    end

    def new_from_linkedin_profile(profile)
      veteran = Veteran.new
      veteran.name = [profile.first_name, profile.last_name].join(" ")
      veteran.email = profile.email_address
      veteran.locations.new(location_type: 'linkedin', full_name: profile.location.name)
      veteran.skills = profile.skills.all.collect do |skill|
        Skill.find_or_create_by(name: skill.skill.name) do |new_skill|
          new_skill.source = 'linkedin_profile'
        end
      end if profile.skills
      profile.educations.all.each do |education|
        start_date = Date.new(education.start_date.year, 1, 1) if education.start_date
        end_date = Date.new(education.end_date.year, 1, 1) if education.end_date
        degree = convert_linkedin_degree(education.degree)
        veteran.experiences.new(experience_type: 'education', educational_organization: education.school_name, credential_type: degree,
                                credential_topic: education.field_of_study, start_date: start_date, end_date: end_date)
      end if profile.educations
      profile.positions.all.sort do |x,y|
        sortable_linkedin_date(y) <=> sortable_linkedin_date(x)
      end.each do |position|
        start_date = Date.new(position.start_date.year, position.start_date.month || 1, 1) if position.start_date
        end_date = Date.new(position.end_date.year, position.end_date.month || 1, 1) if position.end_date
        veteran.experiences.new(experience_type: 'employment', job_title: position.title, organization: position.company.name, description: position.summary,
                                start_date: start_date, end_date: end_date)
      end if profile.positions
      profile.volunteer.volunteer_experiences.all.each do |volunteer|
        veteran.experiences.new(experience_type: 'volunteer', job_title: volunteer.role, organization: volunteer.organization.name)
      end if profile.volunteer and profile.volunteer.volunteer_experiences
      profile.honors_awards.all.each do |award|
        veteran.awards.new(title: award.name, organization: award.issuer)
      end if profile.honors_awards
      veteran
    end

    def convert_linkedin_degree(degree)
      return "Bachelor's Degree" if ["BA", "BS"].include?(degree)
      return "Master's Degree" if ["MA", "MS"].include?(degree)
    end

    def by_minimum_education_level(level)
      t = Experience.arel_table
      valid_levels = EducationLevel.at_least(level)
      self.eager_load(:experiences).
        where(t[:experience_type].eq('education')).
        where(t[:credential_type].in(valid_levels)).
        references(:experiences)
    end

    def ransackable_scopes(auth_object = nil)
      [:by_minimum_education_level]
    end

    def update_searchable_summaries
      includes(:experiences, :affiliations, :awards).find_each(&:update_searchable_summary)
    end

    def sortable_linkedin_date(position)
      return Date.today if position.is_current
      return Date.new(position.end_date.year, position.end_date.month || 1, 1) if position.end_date
      # Use 2 because a position with a start date that matches a position with the same
      # end date should be considered more recent
      return Date.new(position.start_date.year, position.start_date.month || 2, 2) if position.start_date
      return 100.years.ago
    end
  end

  def work_experiences
    experiences = experiences_of_type "employment"
  end

  def educational_experiences
    experiences_of_type "education"
  end

  def volunteer_experiences
    experiences_of_type "volunteer"
  end

  def military_experiences
    experiences_of_type "military"
  end

  def military_and_work_experiences
    (work_experiences + military_experiences).sort {|ex1,ex2| ex2.start_date && ex1.start_date ? ex2.start_date<=>ex1.start_date : ex1.start_date ? -1 : 1}
  end

  def desired_locations
    locations_of_type "desired"
  end

  def has_awards?
    awards.present? && awards.first.title.present?
  end

  def has_skills?
    skills.present?
  end

  def has_affiliations?
    affiliations.present? && affiliations.first.job_title.present?
  end

  def has_references?
    references.present? && references.first.name.present?
  end

  def update_searchable_summary
    summary_text = [
      experiences.map{|e| [e.job_title, e.organization, e.description]},
      affiliations.map{|a| [a.job_title, a.organization]},
      awards.map{|a| [a.title, a.organization]},
      skills.map(&:name),
      [objective, desiredPosition]
    ].flatten.compact.join(" ").gsub(/[[:punct:]]*(\s|^|$)[[:punct:]]*/, ' ')
    # Rip out punctuation adjoining whitespace or beginning or end of string
    # Use the added TSVector class or else rails will try to ram this in
    # as a string, defaulting to the 'simple' dictionary
    # Also, don't mess with the existing instance
    update_column(:searchable_summary, TSVector.new(summary_text, 'english'))
  end

  def update_location_attributes(locations_attributes)
    if !locations_attributes.nil?
      locations_attributes.keys.each do |key|
        if !locations_attributes[key]["id"].nil?
          Location.find(locations_attributes[key]["id"]).update_attributes(full_name: locations_attributes[key]["full_name"])
        end
      end
    end
  end

  private

  def fill_search_summary
    # Don't mess with the existing instance
    Veteran.find(self.id).update_searchable_summary
  end
  add_method_tracer :fill_search_summary, 'Custom/fill_search_summary'

  def experiences_of_type(type)
    experiences.select { |experience| experience.experience_type == type }
  end

  def locations_of_type(type)
    locations.select { |location| location.location_type == type }
  end
end
