class ChangeAlpToDatetime < ActiveRecord::Migration
  def change
    change_column :veterans, :applied_for_alp_date, :datetime
  end
end
