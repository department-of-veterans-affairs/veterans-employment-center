require 'csv'

class UpdateSkillsTable < ActiveRecord::Migration
  def change

    add_column :skills, :belongs_to, :integer

    reversible do |change|
      change.up do
        remove_index(:skills, column: :name)

        Skill.delete_all
        skills = CSV.read('db/seed/skills_corpus.csv', headers: true)
        ActiveRecord::Base.transaction do
          skills.each do |e|
            Skill.create(name: e['skill_name'], source: e['source'], belongs_to: e['belongs_to'], id: e['skill_id'])
          end
        end
        execute "CREATE UNIQUE INDEX  index_skills_on_name ON skills(left(name,1000));"
        execute "ALTER SEQUENCE skills_id_seq RESTART WITH 100000;"
      end

      change.down do
        execute "delete from skills;"
      end

    end

    add_foreign_key :skills, :skills, column: :belongs_to

  end

end
