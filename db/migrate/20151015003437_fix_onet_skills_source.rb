class FixOnetSkillsSource < ActiveRecord::Migration
  def change
    reversible do |change|
      change.up do
        # First, be sure ONET skills are correctly credited to ONET,
        # unless they are also linkedin skills
        puts 'Ensuring O*NET skills have the correct source'
        DeprecatedJobSkill.find_each do |sk|
          s = Skill.find_by(name: sk.name)
          if s.nil?
            puts 'Could not find DeprecatedJobSkill "{sk.name}" in new Skills table'
          else
            src = s.source.downcase
            if src != 'o*net' and src != 'linkedin'
              s.source = 'O*NET'
              s.save
            end
          end
        end
      end
    end
  end
end
