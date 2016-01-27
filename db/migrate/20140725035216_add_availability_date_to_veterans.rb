class AddAvailabilityDateToVeterans < ActiveRecord::Migration
  def change
    add_column :veterans, :availability_date, :date
  end
end
