class AddReinstatementEligibilityToVeteran < ActiveRecord::Migration
  def change
    add_column :veterans, :reinstatement_eligibility, :string
  end
end
