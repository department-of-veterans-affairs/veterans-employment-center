# monkey patch to avoid `index too long` errors. Postgres does not allow
# index names longer than 63 characters
module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements

      def index_name_with_length(table_name, options)
        name = index_name_without_length(table_name, options)
        name = name[0..62] if name.length > 63
        name
      end
      alias_method_chain :index_name, :length

    end
  end
end

class RenameDeprecatedSkillsTables < ActiveRecord::Migration
  def change
    rename_table :job_skills, :deprecated_job_skills
    rename_table :job_skill_matches, :deprecated_job_skill_matches
    rename_column :deprecated_job_skill_matches, :job_skill_id, :deprecated_job_skill_id
  end
end
