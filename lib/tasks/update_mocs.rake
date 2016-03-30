require 'iconv' unless String.method_defined?(:encode)

namespace :db do

  desc 'Update MOC data to source from DoD ODB.'
  task :update_moc_data => :environment do
    csv_text = File.read('db/seed/DOD_ODB_SupportFiles/all_mos.csv')
    if String.method_defined?(:encode)
      csv_text.encode!('UTF-8', 'UTF-8', :invalid => :replace)
    else
      ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
      csv_text = ic.iconv(csv_text)
    end
    csv = CSV.parse(csv_text, headers: true)
    csv.each_with_index do |row, i|
      rowhash = row.to_hash
      rowhash["code "] = rowhash["code "].chop
      mo = MilitaryOccupation.find_or_create_by(code: rowhash["code "], service: rowhash["service"], active: rowhash['status'], category: rowhash['category'])
      mo.description = rowhash['description']
      mo.title = rowhash['title']
      mo.source = rowhash['source']
      mo.updated_at = Time.now
      mo.active = rowhash['status']
      mo.save!
      if i%1000 == 0
	puts i.to_s + ' records updated'
      end
    end
    MilitaryOccupation.where.not(:source => 'DOD_ODB').delete_all
  end
end
