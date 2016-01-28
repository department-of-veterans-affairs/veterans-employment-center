class AddRankToExperience < ActiveRecord::Migration
  def change
    add_column :experiences, :rank, :string
  end
end
