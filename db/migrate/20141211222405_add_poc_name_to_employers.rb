class AddPocNameToEmployers < ActiveRecord::Migration
  def change
    add_column :employers, :poc_name, :string
  end
end
