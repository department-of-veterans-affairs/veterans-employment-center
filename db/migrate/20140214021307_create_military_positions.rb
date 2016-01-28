class CreateMilitaryPositions < ActiveRecord::Migration
  def change
    create_table :military_positions do |t|
      t.string :branch
      t.string :code
      t.string :title

      t.timestamps
    end
  end
end
