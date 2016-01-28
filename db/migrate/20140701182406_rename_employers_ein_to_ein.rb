class RenameEmployersEinToEin < ActiveRecord::Migration
  def change
    rename_column :employers, :EIN, :ein
  end
end
