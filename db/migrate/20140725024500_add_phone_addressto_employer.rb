class AddPhoneAddresstoEmployer < ActiveRecord::Migration
  def change
    add_column :employers, :phone, :string
    add_column :employers, :street_address, :string
    add_column :employers, :city, :string
    add_column :employers, :state, :string
    add_column :employers, :zip, :string
  end
end
