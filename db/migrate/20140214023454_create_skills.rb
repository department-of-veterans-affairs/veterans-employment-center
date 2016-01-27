class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :skill
      t.text :description

      t.timestamps
    end
    
    create_table :military_positions_skills, id: false do |t|
      t.belongs_to :skill
      t.belongs_to :military_position
    end
    
  end
end
