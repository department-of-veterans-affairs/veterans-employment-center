class CreateFavoriteVeterans < ActiveRecord::Migration
  def change
    create_table :favorite_veterans do |t|
      t.integer :veteran_id
      t.integer :employer_id

      t.timestamps
    end
  end
end
