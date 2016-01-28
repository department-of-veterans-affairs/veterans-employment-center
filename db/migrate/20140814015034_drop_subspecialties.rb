class DropSubspecialties < ActiveRecord::Migration
  def up
    drop_table :subspecialties
    drop_table :subspecialties_veterans
  end
  
  def down
    create_table "subspecialties", force: true do |t|
      t.string   "subspecialty"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "subspecialties_veterans", id: false, force: true do |t|
      t.integer "subspecialty_id", null: false
      t.integer "veteran_id",      null: false
    end
  end
end
