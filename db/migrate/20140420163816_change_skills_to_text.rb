class ChangeSkillsToText < ActiveRecord::Migration
  def change
    change_column :veterans, :skills, :text
    change_column :veterans, :desiredLocation, :text
    change_column :veterans, :desiredPosition, :text
  end
end
