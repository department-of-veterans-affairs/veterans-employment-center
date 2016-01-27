class AddCitizenshipToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :citizenship, :string
  end
end
