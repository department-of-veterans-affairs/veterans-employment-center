class UpdateSearchableSummaries < ActiveRecord::Migration
  def change
    @N = Veteran.count
    puts "Updating #{@N} veteran searchable summaries"
    Veteran.find_each.with_index do |v, idx|
      puts "#{idx}/#{@N}" if idx % 100 == 0
      v.update_searchable_summary
    end
  end
end
