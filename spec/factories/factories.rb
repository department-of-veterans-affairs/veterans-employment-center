FactoryGirl.define do
  factory :user do
    email 'test@example.com'
    password '12345678'
    factory :user_with_random_email do
      sequence :email do |n|
        "test+#{n}@example.com"
      end
    end
  end

  factory :linkedinuser, class: User do
    email 'linkedin@goo.com'
    password 'Password'
    provider 'linkedin'
    uid '123'
  end

  factory :veteran do
    name "Joe Veteran"
    email "joe@veteran.org"
  end

  factory :favorite_veteran do
    veteran
    employer
  end

  factory :employer do
  	company_name "Apple Computer"
  	ein 1245
  	street_address "123 Main St"
    city "Towny"
    state "WA"
    zip "22222"
    phone "222-222-3333"
    user
    factory :employer_with_commitments do
      association :user, factory: :user_with_random_email
      commit_date {(rand(3)+1).months.from_now}
      commit_hired {rand(5)}
      commit_to_hire {commit_hired + rand(3)}
    end
  end

  factory :site_feedback do
    url "www.test.com"
    name "Ms Admin"
  end

  factory :award do
    veteran
  end

  factory :experience do
    veteran
  end

  factory :military_experience, class: Experience do
    experience_type "military"
    job_title "Admiral"
    organization "Navy"
  end

  factory :affiliation do
    veteran
  end

  factory :reference do
    veteran
  end

  factory :military_occupation do
    service "Army"
    category "Category 1"
    code "111"
    title "Expert Trainer"
    description "Expert trainers do training"
    active true
  end

  factory :default_military_occupation, class: MilitaryOccupation do
    service "DEFAULT"
    category "Category 1"
    code "DEFAULT"
    title "Default occupation"
    description "Defaults are not at fault."
    active true
  end

  factory :job_title do
    code "333"
    name "Teacher"
    source "O*NET"
  end

  factory :another_job_title, class: JobTitle do
    code "444"
    name "Another Teacher"
    source "O*NET"
  end

  factory :job_title_military_occupation do
    job_title_id "1"
    military_occupation_id "1"
  end

  factory :deprecated_job_skill do
    code   "A1"
    name   "Helpful"
    description "A helpful personality"
  end

  factory :another_deprecated_job_skill, class: DeprecatedJobSkill do
    code   "A2"
    name   "More helpful"
    description "A more helpful personality"
  end

  factory :deprecated_job_skill_match do
    matchable_id "1"
    matchable_type "JobTitle"
    deprecated_job_skill_id "1"
  end


end
