class SiteFeedback < ActiveRecord::Base
  validates_presence_of :description, :message => "A DESCRIPTION is required."
end