class AddIndicesToAwardsAffiliationsEtc < ActiveRecord::Migration
  def change
    add_index :affiliations, :veteran_id
    add_index :awards, :veteran_id
    add_index :references, :veteran_id
  end
end
