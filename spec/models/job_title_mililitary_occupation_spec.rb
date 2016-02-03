require 'rails_helper'

RSpec.describe JobTitleMilitaryOccupation, type: :model do

  let!(:e2) { FactoryGirl.create(:job_title_military_occupation, pay_grade: 'E2') }
  let!(:e6) { FactoryGirl.create(:job_title_military_occupation, pay_grade: 'E6') }

  it 'should filter by pay grade' do
    expect(JobTitleMilitaryOccupation.filter_by_pay_grade('E3').size).to eq(1)
  end

  it 'should filter inclusive of pay grade' do
    expect(JobTitleMilitaryOccupation.filter_by_pay_grade('E-6').size).to eq(2)
  end
end
