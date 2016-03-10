class DropFeedbackTable < ActiveRecord::Migration
  def change
    drop_table :site_feedbacks
  end
end
