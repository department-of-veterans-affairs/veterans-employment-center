class AddDutyStationToExperiences < ActiveRecord::Migration
  def change
    add_column :experiences, :duty_station, :string
  end
end
