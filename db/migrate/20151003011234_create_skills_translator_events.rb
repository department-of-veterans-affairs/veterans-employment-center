class CreateSkillsTranslatorEvents < ActiveRecord::Migration
  def change
    create_table :skills_translator_events do |t|
      t.string :query_uuid, null: false
      t.datetime :browser_timestamp
      t.integer :event_number, null: false
      t.string :event_type, null: false
      t.text :payload
      t.references :skill, foreign_key: true
      t.integer :page
      t.text :shown_skills

      t.timestamps null: false
    end
    add_index :skills_translator_events, :query_uuid, unique: false
  end
end
