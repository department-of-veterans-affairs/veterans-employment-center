class Employer < ActiveRecord::Base
  MAX_COMMIT = ('9'*7).to_i

  belongs_to :user

  validates :user, presence: true
  validates_length_of :location, maximum: 255, allow_blank: true, message: "cannot exceed 255 characters"
  validates_length_of :website, maximum: 255, allow_blank: true, message: "cannot exceed 255 characters"
  validates_length_of :note, maximum: 255, allow_blank: true, message: "cannot exceed 255 characters"
  validates :ein, format: { with: /\A[0-9]+\z/ }, length: { is: 9 }, allow_blank: true
  validates :commit_to_hire, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_COMMIT },
    allow_blank: true
  validates :commit_hired, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_COMMIT }, 
    allow_blank: true
  
  serialize :commitment_categories, Array
  
  COMMITMENT_CATEGORIES = ["Veteran","Homeless","Spouse"]

end
