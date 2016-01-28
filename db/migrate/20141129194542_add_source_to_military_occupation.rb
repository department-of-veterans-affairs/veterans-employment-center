class AddSourceToMilitaryOccupation < ActiveRecord::Migration
  def change
    add_column :military_occupations, :source, :string
  end
end
