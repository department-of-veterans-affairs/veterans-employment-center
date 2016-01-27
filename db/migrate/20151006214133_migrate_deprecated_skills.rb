require 'yaml'

class MigrateDeprecatedSkills < ActiveRecord::Migration
  def change

    reversible do |change|
      change.up do

        p ">>> caching skills"
        name2id = Hash[Skill.all.collect { |s| [s.name, s.id] }]
        inserts = []
        skills_created = []

        p ">>> collecting information from all veterans"
        Veteran.all.each do |veteran|

          next if veteran.deprecated_skills.blank?
          unique_skills = YAML.load(veteran.deprecated_skills).map(&:strip).uniq
          next if unique_skills.blank?

          unique_skills.each do |dep_skill|
            next if dep_skill.empty?

            if name2id[dep_skill]
              inserts.push "(#{veteran.id}, #{name2id[dep_skill]})"
            else
              new_skill = Skill.find_or_create_by(name: dep_skill, source: 'manual')
              inserts.push "(#{veteran.id}, #{new_skill.id})"
              skills_created << dep_skill
            end

          end
        end

        p ">>> massive insert"
        if inserts.any?
          execute "insert into veteran_skills (veteran_id, skill_id) values #{inserts.join(", ")}"
        end

        p ">>> #{skills_created.length} skills not found (-> were created)"
        p skills_created.inspect
      end

      change.down do
        execute "delete from veteran_skills;"
      end
    end

  end
end
