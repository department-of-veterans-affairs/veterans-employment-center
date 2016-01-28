class CreateSubspecialties < ActiveRecord::Migration
  def change
    create_table :subspecialties do |t|
      t.string :subspecialty
      t.text :description

      t.timestamps
    end
  end
end
