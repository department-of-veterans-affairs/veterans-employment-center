class AddIndexOnEmployersCommitToHire < ActiveRecord::Migration
  def change
    add_index :employers, :commit_to_hire
  end
end
