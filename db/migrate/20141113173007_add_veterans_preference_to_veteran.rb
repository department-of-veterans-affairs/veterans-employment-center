class AddVeteransPreferenceToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :veterans_preference, :string
  end
end
