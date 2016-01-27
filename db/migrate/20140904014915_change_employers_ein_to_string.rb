class ChangeEmployersEinToString < ActiveRecord::Migration
  def change
    change_column :employers, :ein, :string
  end
end
