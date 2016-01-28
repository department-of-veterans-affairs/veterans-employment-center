class AddAdminNotesToEmployer < ActiveRecord::Migration
  def change
    add_column :employers, :admin_notes, :string
  end
end
