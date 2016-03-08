class DropAlpDate < ActiveRecord::Migration
  def change
    remove_column :veterans, :applied_for_alp_date
  end
end
