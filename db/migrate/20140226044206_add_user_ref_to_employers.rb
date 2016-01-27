class AddUserRefToEmployers < ActiveRecord::Migration
  def change
    add_reference :employers, :user, index: true
  end
end
