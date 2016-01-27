class Location < ActiveRecord::Base
  belongs_to :veteran
  validates_uniqueness_of :veteran_id, scope: [:full_name, :location_type]

  geocoded_by :full_name, :latitude => :lat, :longitude => :lng
  after_validation :geocode, if: ->(obj){ obj.full_name.present? and obj.full_name? }
  
  reverse_geocoded_by :lat, :lng do |loc, results|
   if geo = results.first
    loc.city = geo.city
    loc.state = geo.state
    loc.zip = geo.postal_code
    loc.country = geo.country_code
   end
  end
  after_validation :reverse_geocode
end