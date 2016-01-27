class CreateEmployers < ActiveRecord::Migration
  def change
    create_table :employers do |t|
      t.string :company_name
      t.integer :EIN
      t.boolean :approved, :default => :false

      t.timestamps
    end
  end
end
