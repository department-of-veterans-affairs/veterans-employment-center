class AddCommonSkillColumn < ActiveRecord::Migration

  def change
    add_column :skills, :is_common, :boolean, default: false

    reversible do |change|
      change.up do
        execute <<-SQL
          update skills set
            is_common = true
          from (
            select
                skill_id,
                skills.name,
                count(1) c
            from veteran_skills
            join skills on veteran_skills.skill_id = skills.id
            where skills.source in ('linkedin', 'bayes')
            group by skill_id, skills.name
            order by c desc
            limit 1000
          ) as common_skills
          where skills.id = common_skills.skill_id;
        SQL
      end
    end
  end
end
