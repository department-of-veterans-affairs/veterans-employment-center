class AddPreparationNeededToJobTitleMilitaryOccupation < ActiveRecord::Migration
  def change
    add_column :job_title_military_occupations, :preparation_needed, :string
    add_column :job_title_military_occupations, :pay_grade, :string
    add_column :job_title_military_occupations, :match_type, :string
  end
end
