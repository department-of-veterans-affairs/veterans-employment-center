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
    end
  end

end
