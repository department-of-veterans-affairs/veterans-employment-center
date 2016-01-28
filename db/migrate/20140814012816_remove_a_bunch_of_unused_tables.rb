class RemoveABunchOfUnusedTables < ActiveRecord::Migration
  def up
    drop_table :civilian_skills
    drop_table :military_positions
    drop_table :military_civilian_careers
    drop_table :military_positions_skills
    drop_table :skills
    drop_table :skills_veterans
  end
  
  def down
    create_table "civilian_skills", force: true do |t|
      t.string   "soc"
      t.string   "skill"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "military_civilian_careers", force: true do |t|
      t.string   "soc"
      t.string   "moc"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "military_positions", force: true do |t|
      t.string   "branch"
      t.string   "code"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "mpc"
      t.string   "status"
      t.text     "description"
    end
    add_index "military_positions", ["code"], name: "index_military_positions_on_code", using: :btree

    create_table "military_positions_skills", id: false, force: true do |t|
      t.integer "skill_id"
      t.integer "military_position_id"
    end
    
    create_table "skills", force: true do |t|
      t.string   "skill"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "category"
      t.string   "external_code"
      t.string   "external_source"
    end

    create_table "skills_veterans", id: false, force: true do |t|
      t.integer "veteran_id", null: false
      t.integer "skill_id",   null: false
    end
  end
end
