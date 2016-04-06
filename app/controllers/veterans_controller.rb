class VeteransController < ApplicationController
  before_action :set_veteran, only: [:show, :edit, :update, :destroy, :favorite, :word]
  before_filter :ensure_employer, only: [:favorites, :favorite]
  before_filter :ensure_employer_or_admin, only: [:index, :download_candidate_veterans]
  before_filter :validate_veteran, only: [:edit, :destroy, :update]
  before_filter :validate_veteran_or_employer, only: [:show, :word]
  before_filter :clean_params, only: [:create, :update]
  before_filter :ensure_admin, only: [:download_all_veterans]

  MULTIPLE_TERM_PATTERN = /\s*,\s*/i
  KEYWORD_FIELD_NAME = 'searchable_summary_cont'

  def index
    veteran_query = Veteran.where.not(user_id: nil).where(visible: true)

    if !(params[:q].blank?) and !((params)[:q]["location"]["full_name"].blank?)
      # Use geocode gem to find locations near where this employer requests
      # TODO: Redefine 'near' once we implement radius preferences for vet's desired locations
      default_radius = 20
      candidate_vet_ids = Location.near(params[:q]["location"]["full_name"],default_radius).map{|loc| loc.veteran_id}

      veteran_query = veteran_query.where(id: candidate_vet_ids.uniq)
    end

    query_params_sans_location = params[:q].except("location") unless params[:q].blank?
    @q = build_search(veteran_query, query_params_sans_location)

    respond_to do |format|
      format.html do
	if ((params)[:q] && !(params)[:q]["by_minimum_education_level"].blank?)
	    @veterans = @q.result.includes(:affiliations, :locations).joins(:experiences).paginate(page: params[:page], per_page: 20).reorder(updated_at: :desc)
        else
            @veterans = @q.result.includes(:experiences, :affiliations, :locations).paginate(page: params[:page], per_page: 20).reorder(updated_at: :desc)
        end
	# Stick the kw query back in as passed to repopulate the text field
        @q.build(KEYWORD_FIELD_NAME => query_params_sans_location[KEYWORD_FIELD_NAME], 'm' => query_params_sans_location['m']) if query_params_sans_location.respond_to?(:keys)
      end
      format.csv do
        columns = Veteran.column_names

        self.response_body = StreamCSV.new("veterans", self.response) do |csv|
          csv << columns
          @q.result.find_each do |veteran|
            csv << columns.map{|c| veteran.send(c)}
          end
        end
      end
    end
  end

  def show
  end

  def download_all_veterans
    @veterans = Veteran.all
    respond_to do |format|
      format.html
      format.csv do
        columns = Veteran.column_names
        self.response_body = StreamCSV.new('veterans', self.response) do |csv|
          csv << columns
          @veterans.each do |veteran|
            csv << columns.map{|c| veteran.send(c)}
          end
        end
      end
    end
  end

  def word
      @for_fed_employment = params[:fed]=="true"
      respond_to do |format|
        format.docx do
          response.headers['Content-Disposition'] = 'attachment; filename="resume.doc"'
          render content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", layout: 'word'
        end
      end
    end

  def favorite
    type = params[:type]
    if type == "favorite"
      current_user.employer.favorites << @veteran
      redirect_to :back
    elsif type == "unfavorite"
      current_user.employer.favorites.delete(@veteran)
      redirect_to :back
    else
      redirect_to :back, notice: 'Nothing.'
    end
  end

  def favorites
    @veterans = current_user.employer.favorites
  end


  # This route is to initialize a new veteran (from the skill-translator or linkedin)
  # and then display this veteran in the resume builder. A veteran object is only
  # create in memory but NOT SAVED to the database (not yet valid, name and email missing).
  # The create method finally creates a new veteran entry in the database.
  def new
    @veteran = session[:linkedin_profile] ? Veteran.new_from_linkedin_profile(session[:linkedin_profile]) : Veteran.new
    @veteran.skills << Skill.find(params[:skills]) if params[:skills].present?
    return if params['moc'].blank? || params['branch'].blank?
    occupation = MilitaryOccupation.find_by_moc_and_branch(params[:moc], params['branch']).first()
    if occupation
      @veteran.experiences << Experience.new({
        moc: occupation.code,
        organization: occupation.service,
        job_title: occupation.title,
        description: occupation.description.gsub(/<\/?p>/i, "\n"),
        experience_type: 'military',
      })
    end
  end

  def edit
  end

  # If an unauthenticated Veteran creates a resume, the veteran_id is saved to a cookie. If they proceed to log in, the cookie links their User to their Veteran.
  def create
    @veteran = Veteran.new(veteran_params)
    if user_signed_in?
      @veteran.update_attributes(user_id: current_user.id) if current_user.veteran.nil?
    else
      request.session[:init] = true
      @veteran.update_attributes(session_id: request.session_options[:id])
    end
    if @veteran.save
      last_event = SkillsTranslatorEvent.where(query_uuid: cookies[:query_uuid])
                                        .order('event_number').last
      SkillsTranslatorEvent.create(
        query_uuid: cookies[:query_uuid],
        event_type: 'VETERAN_CREATED',
        event_number: last_event.event_number + 1,
        payload: {veteran_id: @veteran.id}.to_json) if not last_event.nil?

      cookies[:veteran_id] = @veteran.id
      redirect_to @veteran, notice: 'Veteran was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @veteran.user_id.nil?
      @veteran.update_attributes(user_id: current_user.id) if user_signed_in? && current_user.veteran.nil?
    end
    if !veteran_params["locations_attributes"].blank?
      @veteran.update_location_attributes(veteran_params["locations_attributes"])
    end
    if @veteran.update(veteran_params)
      redirect_to @veteran, notice: 'Veteran was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @veteran.destroy
    redirect_to root_path
  end

  private

  def set_veteran
    @veteran = Veteran.find(params[:id])
  end

  def veteran_params
    params.require(:veteran).permit(
      :name,
      :email,
      :objective,
      :session_id,
      :visible,
      :availability_date,
      references_attributes: [:name, :email, :job_title, :id, :veteran_id, :_destroy],
      affiliations_attributes: [:job_title, :organization, :id, :veteran_id, :_destroy],
      awards_attributes: [:title, :veteran_id, :organization, :date, :id, :_destroy],
      experiences_attributes: [:job_title, :organization, :experience_type, :start_date, :end_date, :hours, :educational_organization, :credential_type, :credential_topic, :description, :veteran_id, :moc, :duty_station, :rank, :id, :_destroy],
      desiredPosition: [],
      status_categories: [],
      locations_attributes: [:id, :veteran_id, :location_type, :full_name, :city, :state, :country, :lat, :lng, :zip, :include_radius, :radius, :_destroy],
    )
  end

  def ensure_employer
    unless !current_user.nil? && current_user.is_employer?
      flash[:error] = "Only signed in employers can view this page"
      redirect_to new_user_session_path
    end
  end

  def ensure_admin
    unless current_user.va_admin?
      flash[:error] = "unauthorized access"
      redirect_to root_path
    end
  end

  def ensure_employer_or_admin
    unless !current_user.nil? && (current_user.is_employer? || current_user.va_admin?)
      flash[:error] = "Only signed in employers or administrators can view this page"
      redirect_to new_user_session_path
    end
  end


  def validate_veteran_or_employer
    if current_user && current_user.is_employer?
      return
    elsif user_owns_veteran?
      return
    else
      redirect_to_employer_login
    end
  end

  def validate_veteran
    redirect_to_employer_login unless user_owns_veteran?
  end

  def user_owns_veteran?
    session_id = request.session_options[:id]
    if session_id && @veteran.session_id == session_id
      true
    elsif !current_user.nil? && current_user == @veteran.user
      true
    else
      false
    end
  end

  def redirect_to_employer_login
    if current_user
      flash[:error] = "You do not have access to that content."
      redirect_to root_path
    else
      flash[:error] = "You must be signed in to access this content."
      redirect_to new_user_session_path
    end
  end

  def clean_params
    clean_blank_params
    clean_date_params(params)
  end

  def clean_blank_params
## TODO: REINSTATE THE BELOW IN TERMS OF NEW MODEL/PARAMS
##    params[:veteran][:desiredLocation].reject!(&:empty?)
    params[:veteran][:status_categories].reject!(&:empty?) unless params[:veteran][:status_categories].nil?
  end

  # Build complex Ransack search group that allows AND operator in keywords.
  #
  # For example, if the keyword is "accounting AND infantry", the built search
  # group should be "if any of the keyword fields contains accounting AND if
  # any of those also contains infantry".
  def build_search(query, params_hash=nil)
    params_hash ||= {}
    # If there are no params or if keyword search is not used, just build a
    # plain Ransack search.
    keyword_query_str = params_hash[KEYWORD_FIELD_NAME].presence
    return query.search(params_hash) unless keyword_query_str

    # Rip the keywords on the AND pattern, do a pg_search search for
    # keywords and ransack for the rest

    keywords = keyword_query_str.split(MULTIPLE_TERM_PATTERN).map{|k| k.gsub(/\s/, '+')}.join(' ')

    if params_hash['m'].downcase == 'or'
      base = query.keyword_search_any(keywords)
    else
      base = query.keyword_search_all(keywords)
    end
    return base.search(params_hash.except(KEYWORD_FIELD_NAME, 'm'))
  end

end
