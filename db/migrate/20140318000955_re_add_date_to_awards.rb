class ReAddDateToAwards < ActiveRecord::Migration
  def change
    remove_column :awards, :date
    add_column :awards, :date, :date
  end
end
