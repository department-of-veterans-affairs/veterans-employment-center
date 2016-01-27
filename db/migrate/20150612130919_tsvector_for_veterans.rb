class TsvectorForVeterans < ActiveRecord::Migration
  def change
    add_column :veterans, :searchable_summary, :tsvector
    add_index :veterans, :searchable_summary, kind: 'gin'
  end
end
