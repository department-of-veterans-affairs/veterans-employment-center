class StreamCSV < Enumerator
  def self.new(filename, response, &block)
    @filename, @response = filename, response
    @response.headers["Content-Type"] ||= 'text/csv'
    @response.headers["Content-Disposition"] = "attachment; filename=#{filename}.csv"
    @response.headers["Content-Transfer-Encoding"] = "binary"
    @response.headers["Last-Modified"] = Time.now.ctime.to_s
    super(block)
  end

  def each(&block)
    super() do |row|
      block.call(row.to_csv)
    end
  end

end
