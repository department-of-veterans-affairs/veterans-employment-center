class AddFederalJobInfoToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :federal_job_info, :string
  end
end
