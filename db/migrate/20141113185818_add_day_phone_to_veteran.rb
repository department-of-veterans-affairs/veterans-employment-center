class AddDayPhoneToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :day_phone, :string
  end
end
