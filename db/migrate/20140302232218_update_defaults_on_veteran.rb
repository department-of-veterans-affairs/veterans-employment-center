class UpdateDefaultsOnVeteran < ActiveRecord::Migration
  def change
    change_column :veterans, :desiredLocation, :string, :default => "--- []\n"
    change_column :veterans, :desiredPosition, :string, :default => "--- []\n"
    change_column :veterans, :skills, :string, :default => "--- []\n"
  end
end

