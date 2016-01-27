class VeteransSkills < ActiveRecord::Migration
 
  	create_join_table :veterans, :skills 

  	
end
