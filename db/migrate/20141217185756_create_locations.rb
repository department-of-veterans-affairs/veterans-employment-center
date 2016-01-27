class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :veteran_id
      t.string :location_type
      t.string :full_name
      t.string :city
      t.string :county
      t.string :state
      t.string :country
      t.decimal :lat, :precision => 10, :scale => 6
      t.decimal :lng, :precision => 10, :scale => 6
      t.string :zip
      t.boolean :include_radius
      t.integer :radius

      t.timestamps
    end
    add_index :locations, :veteran_id
    add_index :locations, [:full_name, :location_type]
  end
end
