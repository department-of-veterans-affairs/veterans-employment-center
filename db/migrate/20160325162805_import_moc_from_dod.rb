require 'iconv' unless String.method_defined?(:encode)

class ImportMocFromDod < ActiveRecord::Migration
  def change
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
      mo = MilitaryOccupation.find_or_create_by(code: rowhash["code "], service: rowhash["service"], active: rowhash['status'])
      MilitaryOccupation.where(code: rowhash["code "], service: rowhash["service"], active: rowhash['status']).find_each do |record|
	if record.id != mo.id
	  record.destroy
        end
      end
      mo.description = rowhash['description']
      mo.title = rowhash['title']
      mo.source = rowhash['source']
      mo.category = rowhash['category']
      mo.updated_at = Time.now
      mo.active = rowhash['status']
      saved = mo.save!
      puts mo.code + ' ' + (saved ? "true" : "false")
    end
  end
end
