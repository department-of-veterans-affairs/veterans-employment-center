## This generates entirely fake data, not used for production.

namespace :db do

  desc 'Seed with fake skills translator model and data'
  task :fictitious_skills_translator => :environment do
    # Create a fake model if it does not exist
    fake_model_name = 'Fake model'
    model = SkillsTranslatorModel.where(description: fake_model_name).take
    if model.nil?
      puts 'Creating fake model'
      model = SkillsTranslatorModel.create(description: fake_model_name)
    end

    fake_skills = Skill.first(100)

    # Fake skill relevances for each military occupation
    # We create one massive insert transaction, so this takes seconds
    # (instead of hours if we just use .create for each record)
    N = MilitaryOccupation.count
    i = 1
    inserts = []
    now = Time.now
    MilitaryOccupation.find_each do |military_occupation|
      if i % 100 == 0
        puts '%d/%d: %s (%d)' % [i, N, military_occupation.title, military_occupation.id]
      end
      i += 1
      fake_skills.each do |s|
        inserts.push "(DEFAULT, %d, %d, %d, %.6f, '%s', '%s')" % [
          model.id, military_occupation.id, s.id, 1.0 / s.name.length, now, now]
      end
    end
    sql = "INSERT INTO skills_for_military_occupations VALUES #{inserts.join(", ")}"
    puts "Executing massive insert query for #{inserts.length} records"
    ActiveRecord::Base.connection.execute(sql)
    puts "Done"
  end

  desc 'Seed with fictitious veterans'
  task :fictitious_veterans, [:number] => :environment do |t, args|
    if args.number.nil?
      puts 'usage: rake db:fictitious_veterans[<integer>]'
    else

      MILITARY_BRANCHES = ["Army", "Navy", "Air Force", "Marines", "Coast Guard"] unless defined? MILITARY_BRANCHES

      (1..args.number.to_i).each do |new_vet_number|
        #Create new fictitious user
        email = "fictitious_vet_"+FFaker::Guid.guid[1..12]+"@adhocteam.us" # guid[1..12] is a random string of (digit|[A..Z]|-) 12 times
        if !User.where(email: email).exists? #It will be extrodinarily rare that the user already exists. In that rare case we skip adding a new user and vet.
          puts "Creating new ficticious USER with email: "+ email if Rails.env == "development"
          user = User.create(email: email,
                             password: "goadhoc111",
                             provider: "adhoc_development"
                            )
          #Create experiences
          puts "Creating ficticious veteran EXPERIENCES" if Rails.env == "development"
          military_experience = Experience.create(experience_type: 'military',
                                                  description: FFaker::HealthcareIpsum.sentences.join(' ') +  " "  + FFaker::HipsterIpsum.sentences.join(' '),
                                                  organization: MILITARY_BRANCHES.shuffle[0],
                                                  job_title: FFaker::Job.title
                                                 )
          educational_experience = Experience.create(experience_type: 'education',
                                                     description: FFaker::HipsterIpsum.sentences.join(' ') +  " "  + FFaker::HealthcareIpsum.sentences.join(' '),
                                                     educational_organization: FFaker::Education.school
                                                    )
          employment_experience = Experience.create(experience_type: 'employment',
                                                    description: FFaker::HealthcareIpsum.sentences.join(' ') +  " "  + FFaker::HipsterIpsum.sentences.join(' '),
                                                    organization: FFaker::Company.name,
                                                    job_title: FFaker::Company.position
                                                   )
          #Create vet
          puts "Creating fictitious  VETERAN for new user", "---" if Rails.env == "development"
          vet = Veteran.create(user_id: user.id,
                         email: email,
                         name: FFaker::Name.name,
                         objective: FFaker::HealthcareIpsum.sentences.join(' ') +  " "  + FFaker::HipsterIpsum.sentences.join(' '),
                         experiences: [military_experience, educational_experience, employment_experience],
                         visible: true,
                         availability_date: Time.now + rand(1..52).weeks
                        )
          Location.create(veteran_id: vet.id, full_name: generate_valid_location)
        end
      end
    end
  end

  desc 'Seed with fictitious affiliations'
  task :fictitious_affiliations, [:number] => :environment do |t, args|
    if args.number.nil?
      puts 'usage: rake db:fictitious_affiliations[<integer>]'
    else
      num_vets = Veteran.all.size
      number_affiliations = args.number.to_i > num_vets ? num_vets : args.number.to_i
      (1..number_affiliations).each do |affiliation|
        vet_id = rand(1..Veteran.last.id)
        vet = Veteran.find_by_id(vet_id)
        unless vet.nil?
          vet.affiliations.create(:job_title => FFaker::Company.position, :organization => FFaker::Company.name)
          puts "Created affiliation for veteran " + vet.id.to_s if Rails.env == "development"
        end
      end
    end
  end


desc 'Seed with fictitious awards'
task :fictitious_awards, [:number] => :environment do |t, args|
  if args.number.nil?
    puts 'usage: rake db:fictitious_awards[<integer>]'
  else
      num_vets = Veteran.all.size
      number_awards = args.number.to_i > num_vets ? num_vets : args.number.to_i
      (1..number_awards).each do |award|
        vet_id = rand(1..Veteran.last.id)
        vet = Veteran.find_by_id(vet_id)
        unless vet.nil?
          vet.awards.create(:title => FFaker::Movie.title, :organization => FFaker::Company.name)
          puts "Created award for veteran " + vet.id.to_s if Rails.env == "development"
        end
      end
    end
  end

private

def generate_valid_location
    country = [:US, :CA, :GB, :DE, :FR].sample
    state = CS.states(country).keys.sample
    city = CS.cities(state, country).sample
    return city + ", " + state.to_s + ", " + CS.countries[country]
end

end
