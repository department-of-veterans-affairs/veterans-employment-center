class AddMailingAddressToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :mailing_address, :text
  end
end
