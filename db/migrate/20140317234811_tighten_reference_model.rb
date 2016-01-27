class TightenReferenceModel < ActiveRecord::Migration
  def change
    rename_column :references, :first_name, :name
    remove_column :references, :last_name
  end
end
