class Experience < ActiveRecord::Base
  belongs_to :veteran, inverse_of: :experiences
  validates_length_of :job_title, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_length_of :organization, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_length_of :educational_organization, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_length_of :credential_type, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_length_of :credential_topic, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_length_of :duty_station, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_length_of :moc, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_inclusion_of :rank, :in => Rank.all, :allow_blank => true, :message => "must be selected from the list"

  def rank=(value)
    write_attribute(:rank, value.to_s.gsub(/[\W]/,'')) if value.present?
  end
end
