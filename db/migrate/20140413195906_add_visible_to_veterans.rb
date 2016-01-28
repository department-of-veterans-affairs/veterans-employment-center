class AddVisibleToVeterans < ActiveRecord::Migration
  def change
    add_column :veterans, :visible, :boolean, :default => false
  end
end
