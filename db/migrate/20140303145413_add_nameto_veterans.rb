class AddNametoVeterans < ActiveRecord::Migration
  def change
    add_column :veterans, :name, :string
  end
end
