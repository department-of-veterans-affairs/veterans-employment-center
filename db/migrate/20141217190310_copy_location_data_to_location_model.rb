class CopyLocationDataToLocationModel < ActiveRecord::Migration
  def change
    Veteran.all.each do |vet|
      vet.desiredLocation.each {|loc| Location.create(veteran_id: vet.id, full_name: loc, location_type: 'desired').save }
    end
  end
end
