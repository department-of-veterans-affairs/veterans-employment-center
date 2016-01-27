class TSVector
  def initialize(source_string, dictionary='simple')
    @source_string, @dictionary = source_string, dictionary
  end

  def quoted_id
    "to_tsvector('#{@dictionary}', '#{quote_string(@source_string)}')"
  end

  def quote_string(value)
    value.gsub(/\\/, '\&\&').gsub(/'/, "''")
  end
  
end
