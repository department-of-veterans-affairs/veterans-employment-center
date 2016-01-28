class AddAdminToUser < ActiveRecord::Migration
  def change
	 	add_column :users, :va_admin, :boolean, :default => false
  end
end
