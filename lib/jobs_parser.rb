class JobsParser

  def self.xml2hash(doc,attrs)
    hash = doc.xpath("//job").map do |job|
      Hash[ attrs.map do |attr| [attr, job.xpath("./"+attr).text] end ]
    end rescue {}
    hash
  end

  def self.x_element(doc, elem)
    return nil if doc.nil?
    doc.xpath("//"+ elem).text
  end
end
