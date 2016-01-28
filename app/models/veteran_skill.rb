class VeteranSkill < ActiveRecord::Base
  belongs_to :veteran
  belongs_to :skill
end
