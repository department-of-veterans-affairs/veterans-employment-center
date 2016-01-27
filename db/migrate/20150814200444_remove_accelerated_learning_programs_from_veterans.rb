class RemoveAcceleratedLearningProgramsFromVeterans < ActiveRecord::Migration
  def change
    remove_column :veterans, :accelerated_learning_programs
  end
end
