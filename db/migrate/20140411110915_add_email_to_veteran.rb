class AddEmailToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :email, :string
  end
end
