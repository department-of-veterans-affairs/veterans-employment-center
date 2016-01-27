class AddExternalCodeAndExternalSourceToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :external_code, :string
    add_column :skills, :external_source, :string
  end
end
