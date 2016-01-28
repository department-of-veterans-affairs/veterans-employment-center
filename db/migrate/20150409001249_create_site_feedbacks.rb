class CreateSiteFeedbacks < ActiveRecord::Migration
  def change
    create_table :site_feedbacks do |t|
      t.text :description
      t.text :how_to_replicate
      t.string :url
      t.string :name
      t.string :email
      t.text :reviewer_comment

      t.timestamps
    end
  end
end
