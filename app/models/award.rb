class Award < ActiveRecord::Base
  belongs_to :veteran
  validates_length_of :title, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
  validates_length_of :organization, :maximum => 255, :allow_blank => true, :message => "cannot exceed 255 characters"
end