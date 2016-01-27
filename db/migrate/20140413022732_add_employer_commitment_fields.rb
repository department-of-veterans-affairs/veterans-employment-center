class AddEmployerCommitmentFields < ActiveRecord::Migration
  def change
    add_column :employers, :website, :string
    add_column :employers, :location, :string
    add_column :employers, :note, :string
  end
end
