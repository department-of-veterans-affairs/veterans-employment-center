class AddAcceleratedLearningProgramToVeterans < ActiveRecord::Migration
  def change
    add_column :veterans, :accelerated_learning_program, :string
  end
end
