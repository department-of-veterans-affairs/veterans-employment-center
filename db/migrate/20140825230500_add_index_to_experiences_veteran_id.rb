class AddIndexToExperiencesVeteranId < ActiveRecord::Migration
  def change
    add_index :experiences, :veteran_id
  end
end
