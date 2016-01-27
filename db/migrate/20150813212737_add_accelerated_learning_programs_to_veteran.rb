class AddAcceleratedLearningProgramsToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :accelerated_learning_programs, :text, :default => []
  end
end
