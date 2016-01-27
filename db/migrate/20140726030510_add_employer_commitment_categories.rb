class AddEmployerCommitmentCategories < ActiveRecord::Migration
  def change
    add_column :employers, :commitment_categories, :string, :default => []
  end
end
