class AddSessionIdToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :session_id, :string, :default => nil
  end
end