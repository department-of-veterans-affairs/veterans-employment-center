class AddPocEmailToEmployers < ActiveRecord::Migration
  def change
    add_column :employers, :poc_email, :string
  end
end
