class CreateSkillsTranslatorModels < ActiveRecord::Migration
  def change
    create_table :skills_translator_models do |t|
      t.text :description

      t.timestamps null: false
    end
  end
end
