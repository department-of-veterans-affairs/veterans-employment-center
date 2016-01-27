class ForceArrayOnVeteranFields < ActiveRecord::Migration
  def change
    change_column :veterans, :desiredLocation, :string, :default => "[]"
    change_column :veterans, :desiredPosition, :string, :default => "[]"
    change_column :veterans, :skills, :string, :default => "[]"
  end
end
