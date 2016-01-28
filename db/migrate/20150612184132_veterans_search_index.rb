class VeteransSearchIndex < ActiveRecord::Migration
  def change
    add_index :veterans, :updated_at
    add_index :veterans, :availability_date
    add_index :veterans, :visible
    add_index :experiences, :moc
    add_index :experiences, :credential_type
  end
end
