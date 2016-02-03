module DataCreator

  def self.get_all_mos
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/all_mos.csv')
    mos_list = CSV.open("db/seed/Mil2FedJobsSupportFiles/mos_list.csv", "a+")
    mos_list1 = CSV.open("db/seed/Mil2FedJobsSupportFiles/mos_list1.csv", "w")
    csv = CSV.parse(csv_text, headers: true)

    all_codes = {}

    csv.each_with_index do |row, i|
      if i % 100 == 0
        puts i
      end
      code = row.to_hash['code']
      all_codes.merge!(get_codes(code))
    end

    all_codes.each do |key, sub_hash|
      mos_list1 << [sub_hash['code'], sub_hash['title'], sub_hash['service'], sub_hash['category'], sub_hash['active'], sub_hash['occupations']]
    end

    puts 'got all codes now'
    all_codes.each do |key, sub_hash|
      mil_occupation = MilitaryOccupation.find_by_code_and_service_and_active(sub_hash['code'], sub_hash['service'], sub_hash['active'])
      if mil_occupation.nil?
        mil_occupation = MilitaryOccupation.create!(sub_hash.except!('occupations'))
      end
      if !sub_hash['occupations'].nil?
        sub_hash['occupations'].each do |occupation|
          job_title = JobTitle.find_by_code(occupation)
          if job_title.nil?
            job_title = JobTitle.create!(code: occupation)
          end
          mil_occupation.job_titles << job_title
        end
      else
        puts key + ' has no occupations'
      end
    end
    puts 'matching definitions now'

    # get definitions matched up
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/all_mos.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      code = rowhash['code']
      # first match up the exact match code descriptions
      if !code.include?('X')
        mil_occupation = MilitaryOccupation.find_by_code_and_service(code, rowhash['service'])
        if (mil_occupation.nil?)
          mil_occupation = MilitaryOccupation.create!(rowhash.merge({active: true}))
          puts 'new MOC created ' + code
        else
          mil_occupation.update!(description: rowhash['description'], source: rowhash['source'])
        end
      else
        # find MOCs that match and update all matching descriptions
        regex_string = code.gsub 'X', '.'
        regex = Regexp.new regex_string
        MilitaryOccupation.all.each do |mo|
          if (!regex.match(mo.code).nil?)
            mo.update!(description: rowhash['description'], source: rowhash['source'])
          end
        end
      end
    end

    mos_list1 = File.read('db/seed/Mil2FedJobsSupportFiles/mos_list1.csv')
    csv = CSV.parse(mos_list1, headers: true)
    csv.each do |row|
      rowhash = row.to_hash
      mo = MilitaryOccupation.find_by_code_and_service_and_active(rowhash['code'], rowhash['service'], rowhash['active'])
      if !mo.nil?
        occupations = YAML.load(rowhash['occupations'])
        mos_list << [mo.code, mo.title, mo.service, mo.category, mo.active, mo.source, occupations, mo.description]
      else
        puts 'no match! ' + rowhash['code'].to_s + ' ' + rowhash['service'].to_s + ' ' + rowhash['active'].to_s
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

  def self.get_onet_jobs_and_skills
    # download this file from ONET http://www.onetcenter.org/taxonomy/2010/list.html
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/2010_Occupations.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1)   if Rails.env == 'test'
    csv.each do |row|
      rowhash = row.to_hash
      code = rowhash["code"]
      # run this to update the jobs in the future
      begin
        overview = HTTParty.post("http://services.onetcenter.org/v1.2/ws/mnm/careers/"+code, {headers: { "Authorization" => "Basic #{ENV['ONET_TOKEN']}"}})
        element = Hash.from_xml((Nokogiri::XML(overview).search("tags").first).to_s)
        tags = element.nil? ? nil : element["tags"]
        is_green = tags.nil? ?  false : tags["green"]=="true"
        has_bright_outlook = tags.nil? ? false: tags["bright_outlook"]=="true"
        has_apprenticeship = tags.nil? ? false: tags["apprenticeship"]=="true"

        job_title_url = "http://www.onetonline.org/link/summary/" + code
        job_title = JobTitle.create!(code: code, name: rowhash["title"], description: rowhash["description"], source: "O*NET", url: job_title_url, is_green: is_green, has_bright_outlook: has_bright_outlook, has_apprenticeship: has_apprenticeship)
      rescue Errno::ECONNRESET, Net::ReadTimeout, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
        puts "handling Errno::ECONNRESET: 1 Connection reset by peer"
        puts code
        codes_not_imported.push(code)
        next
      end
      job_skill_matches = []

      begin
        knowledge_response = HTTParty.post("http://services.onetcenter.org/v1.2/ws/online/occupations/#{code}/summary/knowledge", {headers: { "Authorization" => "Basic #{ENV['ONET_TOKEN']}"}})
        Nokogiri::HTML(knowledge_response).search("element").each do |element|
          job_skill = JobSkill.find_by_code(element.attribute("id").value)
          if (job_skill.nil?)
            job_skill = JobSkill.create!(code: element.attribute("id").value, name: element.search("name").text, description: element.search("description").text, source: "O*NET")
          end
          job_skill_matches.push(job_skill)
        end
      rescue Errno::ECONNRESET, Net::ReadTimeout, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
        puts "handling Errno::ECONNRESET: 2 Connection reset by peer"
        puts code
        codes_not_imported.push(code)
        next
      end

      begin
        skills_response = HTTParty.post("http://services.onetcenter.org/v1.2/ws/online/occupations/#{code}/summary/skills", {headers: { "Authorization" => "Basic #{ENV['ONET_TOKEN']}"}})
        Nokogiri::HTML(skills_response).search("element").each do |element|
          job_skill = JobSkill.find_by_code(element.attribute("id").value)
          if (job_skill.nil?)
            job_skill = JobSkill.create!(code: element.attribute("id").value, name: element.search("name").text, description: element.search("description").text, source: "O*NET")
          end
          job_skill_matches.push(job_skill)
        end
      rescue Errno::ECONNRESET, Net::ReadTimeout, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
        puts "handling Errno::ECONNRESET: 3 Connection reset by peer"
        puts code
        codes_not_imported.push(code)
        next
      end
      job_skill_matches = job_skill_matches.uniq
      for job_skill in job_skill_matches
        job_title.job_skills << job_skill
      end
    end
    puts codes_not_imported unless Rails.env == 'test'
  end


  def self.connect_definitions
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/all_mos.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      code = rowhash['code']
      # first match up the exact match code descriptions
      if !code.include?('X')
        mil_occupation = MilitaryOccupation.find_by_code_and_service(code, rowhash['service'])
        if (mil_occupation.nil?)
          mil_occupation = MilitaryOccupation.create!(rowhash)
        else
          mil_occupation.update!(description: rowhash['description'], source: rowhash['source'])
        end
      else
        # find MOCs that match and update all matching descriptions
        regex_string = code.gsub 'X', '.'
        regex = Regexp.new regex_string
        MilitaryOccupation.all.each do |mo|
          if (!regex.match(mo.code).nil?)
            puts rowhash['source']
            mo.update!(description: rowhash['description'], source: rowhash['source'])
          end
        end
      end
    end
  end

  def self.import_federal_jobs
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/federal_jobs.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1)  if Rails.env == 'test'
    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      if !(MilitaryOccupation.find_by_code(rowhash["code"]))
        MilitaryOccupation.create!(rowhash.except!('type', 'moc_url', 'type', 'status').merge({source: "Mil2Fed"}))
      end
    end
  end

  def self.import_mosdb
    csv_text = File.read('db/seed/Mil2FedJobsSupportFiles/mosdb.csv')
    csv = CSV.parse(csv_text, headers: true)
    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      mo = MilitaryOccupation.find_by_code(rowhash["code"])
      if !mo
        MilitaryOccupation.create!(rowhash.except!('type', 'moc_url', 'type', 'status').merge({source: "mosdb"}))
      else
        if !mo.description
          mo.description = rowhash['description']
          mo.save
        else
          if !(rowhash['description']).include?(mo.description)
            new_description = mo.description + '</p><p>' + rowhash['description']
            mo.description = new_description
            mo.save
          end
        end
      end
    end
  end

  def self.get_codes(code)
    codes_and_titles = {}
    onet_url = "http://www.onetonline.org/crosswalk/MOC?b=&s=" + code + "&g=Go"
    url = URI.parse(onet_url)
    open(url) do |http|
      response = Nokogiri::HTML(http.read).search("table.occ").each_with_index do |table, index|
        table.search('tr').each_with_index do |row, i|
          match = {}
          row.search("td.occcodebold").each do |td|
            match['code'] = td.text.strip()
          end
          row.search('td.occtitlebold').each do |td|
            match['title'] = get_title(td.text)
            match['service'] = get_branch(td.text)
            match['category'] = get_type(td.text)
            match['occupations'] = get_occupations(td)
          end
          if !match.empty?
            if (index == 0)
              match['active'] = true
            elsif (index == 1)
              match['active'] = false
            end
            key = match['code'] + match['service'] + match['active'].to_s
            codes_and_titles[key] = match
          end
        end
      end
    end
    return codes_and_titles
  end; nil

  def self.get_occupations(occupation_text)
    occupation_list = []
    table = occupation_text.search('table.occcompact')
    table.search('tr').each do |row|
      occupation = {}
      occupation['code'] = row.search('td.occcompactcode').text
      occupation['title'] = row.search('td.occcompacttitle').text.strip()
      if !occupation.empty?
        occupation_list.push(occupation['code'])
      end
    end
    return occupation_list
  end

  def self.get_title(row_string)
    remove = row_string.scan(/.\([a-zA-Z\s]+.\-.[a-zA-Z\s]+\)/)
    if remove.length > 0
      title = row_string.split(remove[0])[0]
      return title
    else
      return nil
    end
  end

  def self.get_type(row_string)
    matches = {
      'Commissioned or Warrant Officer' => 'Commissioned or Warrant Officer',
      'Warrant Officer only' => 'Warrant Officer',
      'Enlisted' => 'Enlisted',
      'Commissioned Officer only' => 'Officer',
      'Billets and Personnel' => 'Billets and Personnel',
      'Personnel Only' => 'Personnel'}
    matches.each_pair do |key, value|
      if row_string.include?(key)
        return value
      end
    end
    return nil
  end

  def self.get_branch(row_string)
    matches = ['Marine Corps ', 'Army ', 'Navy ', 'Air Force ', 'Coast Guard ']
    matches.each do |m|
      if row_string.include?(m)
        return m.strip()
      end
    end
    return nil
  end

  def self.code_exists(code)
    response = HTTParty.post("http://services.onetcenter.org/ws/veterans/military", {headers: { "Authorization" => "Basic #{ENV['ONET_TOKEN']}"}, body: {keyword: code}})
    return Nokogiri::HTML(response).search("career").length > 0
  end

  # load 'db/seed/data_creator.rb'; DataCreator.get_preparation_needed
  def self.get_preparation_needed
    rows = [["military_occupation_id", "job_code", "preparation_needed", "match_type", "pay_grade"]]
    i = 0
    mos = MilitaryOccupation.all.length.to_f

    MilitaryOccupation.all.each do |mo|
      url = "http://services.onetcenter.org/v1.4/ws/veterans/military?keyword=#{mo.code.upcase}"
      resp = HTTParty.post(url, {headers: {"Authorization" => "Basic #{ENV['ONET_TOKEN']}"}})
      if resp.code == 200
        xml = Nokogiri::XML(resp.body)
        xml.search('careers/career').each do |career|
          match_type = career.attributes["match_type"].text
          code = career.search('code').text

          prep = nil
          if career.search('preparation_needed').length > 0
            prep = career.search('preparation_needed').text
          end

          pay_grade = nil
          if career.search('pay_grade').length > 0
            pay_grade = career.search('pay_grade').text
          end

          row = [mo.id, code, prep, match_type, pay_grade]
          rows << row

          if i % 100 == 0
            puts "#{i}, #{format("%.2f", i/mos)}, #{row}"
          end
          i += 1
        end
      end
    end

    CSV.open("db/seed/military_careers.csv", 'w') do |csv|
      rows.each do |row|
        csv << row
      end
    end
  end
end
