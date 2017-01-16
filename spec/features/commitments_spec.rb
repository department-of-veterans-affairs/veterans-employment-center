require 'rails_helper'
describe '/commitments', js: true, driver: :poltergeist do
  before do
    11.times do
      FactoryGirl.create(:employer_with_commitments, approved: true)
    end
    FactoryGirl.create(:employer_with_commitments, company_name: 'Searchable', approved: true)
    visit '/commitments'
  end

  it 'should list the employers' do
    expect_rows(10)
  end

  it 'should change paging size' do
    select '25', from: 'commitments_length'
    expect_rows(12)
  end

  it 'should search' do
    find('input[type="search"]').set('searcha')
    expect_rows(1)
  end

  it 'should paginate' do
    find('a', text: 'Next').trigger(:click)
    expect_rows(2)
  end

  pending 'should change sort', js: true do
    company_header = find('th', text: 'Company')
    company_header.trigger('click')
    company_header.trigger('click')
    expect(page).to have_no_content 'Processing'
    expect(first_row).to have_content 'Searchable'
    expect(true).to be_false # remove this when you fix the test; it's just here to make this spec fail.
  end
end
