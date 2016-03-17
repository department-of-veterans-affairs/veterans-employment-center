require 'rails_helper'
describe '/employer-list', js: true, driver: :webkit do
  before do
    12.times do
      FactoryGirl.create(:employer_with_commitments)
    end
    sign_in_as_admin
    visit employer_list_path
  end

  after do
    logout
  end

  it 'should download employers' do
    User.connection.transaction do
      10.times do
        uwre = FactoryGirl.build(:user_with_random_email)
        uwre.save(validate: false)
        ewc = FactoryGirl.build(:employer_with_commitments, user: uwre)
        ewc.save(validate: false)
      end
    end
    click_link 'Download a spreadsheet'
    employer_check = Employer.order(:id).last
    expect(page.body).to include([employer_check.id, employer_check.company_name].join(','))
  end
  
  it 'should list the employers' do
    expect_rows(12)
  end

  it 'should change paging size' do
    select '10', from: 'employers_length'
    expect_rows(10)
  end

  it 'should search' do
    find('input#keywords').set(Employer.first.user.email)
    click_button('employer-search')
    expect_rows(1)
  end

  it 'should paginate' do
    select '10', from: 'employers_length'
    find('a', text: 'Next').trigger(:click)
    expect_rows(2)
  end
  
  it 'should change sort' do
    expect(page).to have_no_content "Processing"
    expect(first_row).to have_content Employer.order("created_at DESC").first.user.email
    email_header = find('th', text: 'Email')
    email_header.trigger('click')
    expect(page).to have_no_content "Processing"
    first_by_email = Employer.eager_load(:user).order(User.arel_table[:email].asc).first.user.email
    expect(first_row).to have_content first_by_email
    email_header.trigger('click')
    expect(page).to have_no_content "Processing"
    last_by_email = Employer.eager_load(:user).order(User.arel_table[:email].desc).first.user.email
    expect(first_row).to have_content last_by_email
  end
end
  
