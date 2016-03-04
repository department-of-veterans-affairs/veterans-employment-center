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

end
