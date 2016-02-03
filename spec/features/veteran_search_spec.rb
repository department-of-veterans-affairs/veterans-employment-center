require 'rails_helper'

describe 'Veteran Search' do

  context 'when there are no search results' do
    it "should display 0 results" do
      @user1 = User.create(email: 'suzy@veteran.org', password: 'Password')
      @user2 = User.create(email: 'robin.h@sherwood.org', password: 'Password')
      @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1
      @vet2 = create :veteran, name: "Robin Hood", desiredPosition: ["Archer, Leader, Teacher"], objective: "Become a better person. Help others.",  user: @user2
      approved_employer = employer_user
      approved_employer.employer.update_attributes(approved: true)
      sign_in_as approved_employer
      visit veterans_path
      fill_in 'keywords', with: 'learn'
      click_button('veteran-search')
      expect(page).to have_content "0 Results"
    end
  end

  context 'when there are search results' do

    before do
      @user1 = User.create(email: 'suzy@veteran.org', password: 'Password')
      @user2 = User.create(email: 'robin.h@sherwood.org', password: 'Password')
      approved_employer = employer_user
      approved_employer.employer.update_attributes(approved: true)
      sign_in_as approved_employer
      visit veterans_path
      fill_in 'keywords', with: 'learn'
    end

    context 'when there are multiple results' do
      before do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Robin Hood", desiredPosition: ["Archer, Leader, Teacher"], objective: "1. Become a better person. Learn to help others.",  user: @user2, visible: true
        @vet1.update_column(:updated_at, 10.minutes.ago)
      end

      it 'should display in recent first order' do
        visit veterans_path
        vets = all('.vet_profile_link')
        expect(vets[0]).to have_content @vet2.objective
        expect(vets[1]).to have_content @vet1.objective
      end
    end

    context 'when there are results per veteran objective' do
      it "should display results from objective match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Robin Hood", desiredPosition: ["Archer, Leader, Teacher"], objective: "1. Become a better person. Learn to help others.",  user: @user2, visible: true
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet2.objective
      end
    end

    context 'when there are multiple results for a veteran objective' do
      it 'should download a CSV' do
        User.connection.transaction do
          10.times do
            u = FactoryGirl.build(:user_with_random_email)
            u.save(validate: false)
            vet = FactoryGirl.build(:veteran, name: "Robin Hood", desiredPosition: ["Archer, Leader, Teacher"], objective: "1. Become a better person. Learn to help others.",  user: u, visible: true)
            vet.save(validate: false)
          end
          click_button('veteran-search')
          find('a', text: 'Download a spreadsheet', visible: false).click
          veteran_check = Veteran.order(:id).last
          expect(page.body).to include([veteran_check.name, veteran_check.email].join(','))
        end
      end
    end

    context 'when there are results per veteran desiredPosition' do
      it "should display results from desiredPosition match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet3 = create :veteran, name: "Robin Hood", desiredPosition: ["Archer, Learner, Teacher"], objective: "2. Become a better person. Try to help others.",  user: @user2, visible: true
        @vet1.save
        @vet3.save
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet3.objective
      end
    end

    context 'when there are results per veteran skills' do
      it "should display results from skills match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet4 = create :veteran, name: "Robin Hood", objective: "3. Become a better person. Try to help others. ",  user: @user2, visible: true
        @s = Skill.create(name: 'Learner', source: 'Test source')
        VeteranSkill.create(veteran: @vet4, skill: @s)
        @vet1.save
        @vet4.save
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet4.objective
      end
    end

    context 'when there are results per veteran experience.description' do
      it "should display results from experience.description match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet5 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true, experiences_attributes: [{description: "Taught the group how to learn."}]
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet5.objective
      end
    end

    context 'when there are results per veteran experience.job_title' do
      it "should display results from experience.job_title match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet6 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true
        experience = create :experience, veteran: @vet6, job_title: "Learner"
        @vet1.save
        @vet6.save
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet6.objective
      end
    end

    context 'when there are results per veteran award.title' do
      it "should display results from award.title match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true
        award = create :award, veteran: @vet1, title: "Purple Heart"
        @vet1.save
        @vet2.save
        fill_in 'keywords', with: 'purple'
        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_no_content @vet2.objective
      end
    end

    context 'when there are results per veteran award.organization' do
      it "should display results from award.organization match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true
        award1 = create :award, veteran: @vet1, title: "Purple Heart", organization: "Some Division X"
        award2 = create :award, veteran: @vet2, title: "Purple Heart", organization: "Another Division Y"
        @vet1.save
        @vet2.save
        fill_in 'keywords', with: 'division x'
        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_no_content @vet2.objective
      end
    end

    context 'when there are results per veteran affiliation.job_title' do
      it "should display results from affiliation.job_title" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true
        affiliation = create :affiliation, veteran: @vet1, job_title: "Committee Chair", organization: "Some Association"
        @vet1.save
        @vet2.save
        fill_in 'keywords', with: 'chair'
        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_no_content @vet2.objective
      end
    end

    context 'when there are results per veteran affiliation.organization' do
      it "should display results from affiliation.organization" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true
        affiliation1 = create :affiliation, veteran: @vet1, job_title: "Committee Chair", organization: "Some Association"
        affiliation2 = create :affiliation, veteran: @vet2, job_title: "Committee Chair", organization: "Some Society"
        @vet1.save
        @vet2.save
        fill_in 'keywords', with: 'society'
        click_button('veteran-search')
        expect(page).to have_content @vet2.objective
        expect(page).to have_no_content @vet1.objective
      end
    end

    context 'when there are results per veteran.availability_date' do
      it "should display results for proper availability dates-i.e., before or equal to date employer selected" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true, availability_date: "2017-01-01"
        @vet2 = create :veteran, name: "Max Veteran", objective: "Build greater web apps.", user: @user2, visible: true, availability_date: "2016-12-01"
        @vet5 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true, availability_date: "2017-01-02"
        select('January', from: 'q_availability_date_lteq_2i')
        select('1', from: 'q_availability_date_lteq_3i')
        select('2017', from: 'q_availability_date_lteq_1i')
        experience = create :experience, veteran: @vet1,  job_title: "Learner"
        experience = create :experience, veteran: @vet2,  job_title: "Learner"
        experience = create :experience, veteran: @vet5,  job_title: "Learner"
        @vet1.save
        @vet2.save
        @vet5.save
        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_content @vet2.objective
        expect(page).to have_no_content @vet5.objective
      end
    end

    context 'when there are results per veteran experience.moc' do
      before do
        fill_in 'keywords', with: ''
        fill_in 'moc', with: '210'
      end
      it "should display results from experience.job_title match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet6 = create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true
        experience = create :experience, veteran: @vet6, job_title: "teacher", moc: "210"
        @vet1.save
        @vet6.save
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet6.objective
      end
    end

    context 'when there are results per accelerated learning program  (ALP) applicant' do
      before do
        fill_in 'keywords', with: ''
        select 'Yes', from: 'Applied for Accelerated Learning Program'
      end
      it "should display results from ALP match" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Robin Hood", objective: "Do great things", applied_for_alp_date: "2016-01-02",  user: @user2, visible: true
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet2.objective
      end
    end

    context 'when there are results per veteran experience.education_level' do
      before do
        fill_in 'keywords', with: ''
        select EducationLevel::LEVELS[6], from: 'Minimum Education Level'
      end
      it "should display results from experience.education_level match" do
        @vet1 = FactoryGirl.create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet6 = FactoryGirl.create :veteran, name: "Robin Hood",  objective: '4. Become a better person. Try to help others.', user: @user2, visible: true
        FactoryGirl.create :experience, veteran: @vet1, experience_type: 'education', credential_type: EducationLevel::LEVELS[5]
        FactoryGirl.create :experience, veteran: @vet6, experience_type: 'education', credential_type: EducationLevel::LEVELS[5]
        FactoryGirl.create :experience, veteran: @vet6, experience_type: 'education', credential_type: EducationLevel::LEVELS[7]
        click_button('veteran-search')
        expect(page).to have_no_content @vet1.objective
        expect(page).to have_content @vet6.objective
      end
    end

    context 'when AND operator is used' do
      it "should display results that have a field matching both keywords" do
        @user3 = User.create(email: 'robin.h@sherwood.org', password: 'Password')
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Max Veteran",  objective: "Build great business apps", user: @user2, visible: true
        @vet3 = create :veteran, name: "Robin Hood",  objective: "Help urban development", user: @user3, visible: true

        experience = create :experience, veteran: @vet1, job_title: "Software developer"
        experience = create :experience, veteran: @vet2, job_title: "Developer (senior, software)"
        experience = create :experience, veteran: @vet3, job_title: "Land developer"
        @vet1.save
        @vet2.save
        @vet3.save

        fill_in 'keywords', with: 'software, developer'
        select 'all', from: 'Match'

        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_content @vet2.objective
        expect(page).to have_no_content @vet3.objective
      end

      it "should display results that have a keyword in one field and another keyword in another field" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build a career with my infantry experience.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Max Veteran",  objective: "Build great business apps", user: @user2, visible: true
        experience = create :experience, veteran: @vet1, job_title: "Accounting Manager"
        experience = create :experience, veteran: @vet2, job_title: "Accounting Manager"
        @vet1.save
        @vet2.save

        fill_in 'keywords', with: 'accounting, infantry'

        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_no_content @vet2.objective
      end

      it "should display results that match three keywords across different fields" do
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build a career with my infantry experience.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Max Veteran", objective: "Build a new career, with my infantry experience.", user: @user2, visible: true
        experience = create :experience, veteran: @vet1, job_title: "Accounting Manager", description: "Managed a team at a software company"
        experience = create :experience, veteran: @vet2, job_title: "Accounting Manager"
        @vet1.save
        @vet2.save
        # Case shouldn't matter.
        fill_in 'keywords', with: 'accounting, Infantry, software'

        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_no_content @vet2.objective
      end
    end

    context 'when OR operator is used' do
      it "should display results that have a field matching both keywords" do
        @user3 = User.create(email: 'robin.h@sherwood.org', password: 'Password')
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Max Veteran",  objective: "Build great business apps", user: @user2, visible: true
        @vet3 = create :veteran, name: "Robin Hood",  objective: "Help urban development", user: @user3, visible: true
        experience = create :experience, veteran: @vet1, job_title: "Software developer"
        experience = create :experience, veteran: @vet2, job_title: "Developer (senior, software)"
        experience = create :experience, veteran: @vet3, job_title: "Land developer"
        @vet1.save
        @vet2.save
        @vet3.save

        fill_in 'keywords', with: 'software, developer'
        select 'any', from: 'Match'
        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_content @vet2.objective
        expect(page).to have_no_content @vet3.objective
        expect(page.find('select#q_m').value).to eq('or')
      end

      it "should display results that have a field matching either keyword" do
        @user3 = User.create(email: 'robin.h@sherwood.org', password: 'Password')
        @vet1 = create :veteran, name: "Suzy Veteran", objective: "Build great web apps.", user: @user1, visible: true
        @vet2 = create :veteran, name: "Max Veteran",  objective: "Build great business apps", user: @user2, visible: true
        @vet3 = create :veteran, name: "Robin Hood",  objective: "Help urban development", user: @user3, visible: true
        experience = create :experience, veteran: @vet1, job_title: "Software developer"
        experience = create :experience, veteran: @vet2, job_title: "Developer (senior, software)"
        experience = create :experience, veteran: @vet3, job_title: "Land developer"
        @vet1.save
        @vet2.save
        @vet3.save


        fill_in 'keywords', with: 'software, farmer'
        select 'any', from: 'Match'
        click_button('veteran-search')
        expect(page).to have_content @vet1.objective
        expect(page).to have_content @vet2.objective
        expect(page).to have_no_content @vet3.objective
      end
    end


  end

end

