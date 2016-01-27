class RemoveColumnsFromVeterans < ActiveRecord::Migration
  def change
    remove_column :veterans, :citizenship, :string
    remove_column :veterans, :veterans_preference, :string
    remove_column :veterans, :reinstatement_eligibility, :string
    remove_column :veterans, :federal_job_info, :string
    remove_column :veterans, :mailing_address, :text
    remove_column :veterans, :day_phone, :string
    remove_column :veterans, :evening_phone, :string
    remove_column :veterans, :highest_grade_held, :string
  end
end
