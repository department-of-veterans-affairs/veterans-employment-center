EmploymentPortal::Application.configure do
  config.after_initialize do
    if Veteran.table_exists? && Veteran.column_names.include?('searchable_summary')
      if Veteran.where.not(:searchable_summary => nil).count == 0
        Thread.new do
          Veteran.update_searchable_summaries
        end
      end
    end
  end
end
