class AddFieldsToRatings < ActiveRecord::Migration
  def change
    remove_column :ratings, :stars
    add_column :ratings, :question_1, :integer
    add_column :ratings, :question_2, :integer
    add_column :ratings, :question_3, :integer
    add_column :ratings, :question_4, :integer
    add_reference :ratings, :user, index: true
    add_column :ratings, :data, :text
  end
end
