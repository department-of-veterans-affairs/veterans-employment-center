class AddAppliedForAlpDateToVeterans < ActiveRecord::Migration
  def change
    add_column :veterans, :applied_for_alp_date, :date
  end
end
