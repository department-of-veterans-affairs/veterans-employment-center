namespace :search do
  desc "update searchable_summaries for veterans"
  task update_veterans: :environment do
    Veteran.update_searchable_summaries
  end
end
