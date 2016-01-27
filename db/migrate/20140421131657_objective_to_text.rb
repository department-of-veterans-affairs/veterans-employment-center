class ObjectiveToText < ActiveRecord::Migration
  def change
    change_column :veterans, :objective, :text, :limit => nil
  end
end
