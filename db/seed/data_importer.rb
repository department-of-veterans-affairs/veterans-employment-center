module DataImporter

  def self.import_all_mos
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/mos_list.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1)  if Rails.env == 'test'
    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      code = rowhash['code']
      mil_occupation = MilitaryOccupation.find_by_code_and_service_and_active(rowhash['code'], rowhash['service'], rowhash['active'])
      if mil_occupation.nil?
        mil_occupation = MilitaryOccupation.create!(rowhash.except!('occupations'))
      end
      if mil_occupation.description.nil?
        mil_occupation.description = ""
        mil_occupation.save!
      end
      rowhash = row.to_hash
      occupations = YAML.load(rowhash['occupations'])
      occupations.each do |occupation|
        job_title = JobTitle.find_by_code(occupation)
        if job_title.nil?
          job_title = JobTitle.create!(code: occupation)
        end
        mil_occupation.job_titles << job_title
      end
      get_skills(mil_occupation)
    end
  end

  def self.import_ONET_job_skills
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/skills.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1) if Rails.env == 'test'
    csv.each do |row|
      rowhash = row.to_hash
      if !(DeprecatedJobSkill.find_by_code(rowhash['code']))
        DeprecatedJobSkill.create!(rowhash)
      end
    end
  end

  def self.import_ONET_jobs
    codes_not_imported = []

    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/2010_Occupations.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1)   if Rails.env == 'test'
    csv.each do |row|
      rowhash = row.to_hash
      code = rowhash["code"]
      job_title = JobTitle.find_by_code(code)
      if (job_title.nil?)
        job_title = JobTitle.create!(rowhash.except('job_skills'))
      else
        job_title.update!(rowhash.except('job_skills'))
      end
      rowhash = row.to_hash
      deprecated_job_skills = YAML.load(rowhash['job_skills'])
      deprecated_job_skills.each do |skill_code|
        s = DeprecatedJobSkill.find_by_code(skill_code)
        if s.nil?
          s = DeprecatedJobSkill.create!(code: skill_code)
        end
        job_title.deprecated_job_skills << s
      end
    end
  end

  def self.import_federal_jobs
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/federal_jobs.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1)  if Rails.env == 'test'
    csv.each do |row|
      rowhash = row.to_hash
      if !(JobTitle.find_by_code(rowhash["code"]))
        JobTitle.create!(rowhash.except!('type', 'group_code', 'status','footnote').merge({source: "Mil2Fed"}))
      end
    end
  end

  def self.connect_federal_jobs_to_mocs
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/XWALK.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1)  if Rails.env == 'test'
    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      job_title = JobTitle.find_by_code(rowhash["job_title_id"])
      if (job_title.nil?)
        job_title = JobTitle.create!(code: rowhash['job_title_id'], name: rowhash['title'])
      end

      code = rowhash['military_occupation_id']
      # if there is a direct code match
      if !code.include?('X')
        mil_occupation = MilitaryOccupation.find_by_code(code)
        if (mil_occupation.nil?)
          mil_occupation = MilitaryOccupation.create!(title: rowhash['service_title'], code: code, service: rowhash['service'], category: rowhash['personnel_category'], source: "Mil2Fed")
        end
        if (!job_title.nil? && !mil_occupation.nil?)
          JobTitleMilitaryOccupation.create!(job_title_id: job_title.id, military_occupation_id: mil_occupation.id)
        end
      # find MOCs that match and save the relationships
      else
        regex_string = code.gsub 'X', '.'
        regex = Regexp.new regex_string
        MilitaryOccupation.all.each do |mo|
          if (!regex.match(mo.code).nil?)
            JobTitleMilitaryOccupation.create!(job_title_id: job_title.id, military_occupation_id: mo.id)
          end
        end
      end
    end
  end

  def self.get_skills(mil_occupation)
    skill_set = []
    mil_occupation.job_titles.each do |job_title|
      skill_set += job_title.deprecated_job_skills
    end
    skill_set = skill_set.uniq
    skill_set.each do |job_skill|
      mil_occupation.deprecated_job_skills << job_skill
    end
  end

  # load 'db/seed/data_importer.rb'; DataImporter.link_military_careers
  def self.link_military_careers
    rows = CSV.open("db/seed/military_careers.csv")
    #skip headers
    rows.shift
    job_titles = JobTitle.all.map{|jt| [jt.code, jt]}.to_h
    rows.each do |row|
      military_occupation_id, job_code, preparation_needed, match_type, pay_grade = row
      job  = job_titles[job_code]
      if job.nil?
        #puts "Unable to find job #{job_code}. This is OK for the specs, but not OK in production"
        next
      end

      join = JobTitleMilitaryOccupation.find_by("job_title_id=? and military_occupation_id=?",
                                                job.id, military_occupation_id)
      if join.nil?
        join = JobTitleMilitaryOccupation.create(job_title_id: job.id,
                                                 military_occupation_id: military_occupation_id,
                                                 preparation_needed: preparation_needed,
                                                 match_type: match_type,
                                                 pay_grade: pay_grade,
                                                )
      else
        join.preparation_needed = preparation_needed
        join.match_type = match_type
        join.pay_grade = pay_grade
        join.save
      end
    end
  end
end
