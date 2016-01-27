class AddEveningPhoneToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :evening_phone, :string
  end
end
