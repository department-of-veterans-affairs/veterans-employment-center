class FavoriteVeteran < ActiveRecord::Base
  belongs_to :employer
  belongs_to :veteran
end