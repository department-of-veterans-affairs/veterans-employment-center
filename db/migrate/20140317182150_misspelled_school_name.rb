class MisspelledSchoolName < ActiveRecord::Migration
  def change
    rename_column :experiences, :educational_organziation, :educational_organization
  end
end
