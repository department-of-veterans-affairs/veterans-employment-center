require 'iconv' unless String.method_defined?(:encode)

module DataImporter

  def self.import_all_mos
    csv_text = File.read('db/seed/DOD_ODB_SupportFiles/all_mos.csv')
    if String.method_defined?(:encode)
      csv_text.encode!('UTF-8', 'UTF-8', :invalid => :replace)
    else
      ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
      csv_text = ic.iconv(csv_text)
    end
    csv = CSV.parse(csv_text, headers: true)
    csv = csv.take(1)  if Rails.env == 'test'

    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      rowhash["code"] = rowhash["code "].chop
      rowhash['active'] = rowhash['status']
      rowhash.delete('status')
      rowhash.delete("code ")
      mil_occupation = MilitaryOccupation.find_by_code_and_service_and_active(rowhash['code'], rowhash['service'], rowhash['active'])
      if mil_occupation.nil?
        mil_occupation = MilitaryOccupation.create!(rowhash)
      end
      if mil_occupation.description.nil?
        mil_occupation.description = ""
        mil_occupation.save!
      end
    end
  end

end
