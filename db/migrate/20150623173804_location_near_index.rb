class LocationNearIndex < ActiveRecord::Migration
  def change
    add_index :locations, [:lat, :lng]
  end
end
