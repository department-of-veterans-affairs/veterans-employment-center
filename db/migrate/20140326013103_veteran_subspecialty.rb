class VeteranSubspecialty < ActiveRecord::Migration
  
   create_join_table :subspecialties, :veterans
end
