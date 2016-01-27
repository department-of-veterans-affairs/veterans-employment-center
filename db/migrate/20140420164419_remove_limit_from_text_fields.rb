class RemoveLimitFromTextFields < ActiveRecord::Migration
  def change
    change_column :veterans, :skills, :text, :limit => nil
    change_column :veterans, :desiredLocation, :text, :limit => nil
    change_column :veterans, :desiredPosition, :text, :limit => nil
  end
end
