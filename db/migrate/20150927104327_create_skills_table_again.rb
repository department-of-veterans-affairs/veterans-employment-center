class CreateSkillsTableAgain < ActiveRecord::Migration
  def change
    create_table (:skills) do |t|
        t.text :name
        t.text :source

        t.timestamps null: false
    end
    add_index :skills, :name
  end
end
