class AddUserIdToVeterans < ActiveRecord::Migration
  def change
    add_column :veterans, :user_id, :integer
    add_index :veterans, :user_id
  end
end
