namespace :scheduler do
  desc "Purge those veteran records older than 1 day and unassociated with a user account."
  task purge_unassociated_veteran_records: :environment do
    log = Logger.new("log/scheduler-veteran_purges.log")
    log.info(":scheduler:: "+Veteran.purge(1.day.ago).to_s+" unassociated veteran record(s) purged")
  end

end
