class CreateMilitaryOccupations < ActiveRecord::Migration
  def change
    create_table :military_occupations do |t|
      t.string :service
      t.string :category
      t.string :code
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
