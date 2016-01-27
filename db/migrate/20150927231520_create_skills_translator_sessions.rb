class CreateSkillsTranslatorSessions < ActiveRecord::Migration
  def change
    create_table :skills_translator_sessions do |t|
      t.string :query_uuid, null: false
      t.datetime :query_timestamp, null: false
      t.text :query_params, null: false
      t.references :skills_translator_model, index: true, foreign_key: true, null: false
      t.text :session_data
      t.datetime :session_data_timestamp

      t.timestamps null: false
    end
    add_index :skills_translator_sessions, :query_uuid, unique: true
  end
end
