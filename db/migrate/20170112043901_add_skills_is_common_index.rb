class AddSkillsIsCommonIndex < ActiveRecord::Migration
  def change
    add_index :skills, :is_common
  end
end
