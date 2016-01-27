#!/usr/bin/env ruby
require 'getoptlong'
require 'pg'

if !((ARGV.length <= 2) || (ARGV.length == 4))
  puts "Missing start and/or number_of_records_to_process arguments (try --help)"
  exit 0
end


opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--start', '-s', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--num', '-n', GetoptLong::OPTIONAL_ARGUMENT ]
)

off_set = 0
lim = 2000

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
geocode_locations [OPTION]  

-h, --help:
   show help

-s, --start x:
   starting at the xth db record; default = 1

-n, --num x:
   process x number of records; default = 2000 
      EOF
      exit(0)
    when '--start'
      off_set = arg.to_i - 1
    when '--num'
      arg.to_i <= lim ? lim = arg.to_i : true
  end

end

require '../config/environment'

Location.limit(lim).offset(off_set).not_geocoded.each_with_index do |loc, i|
  begin
    loc.geocode
    loc.save
    puts "Geocoded record #" + loc.id.to_s
  rescue NoMethodError
    puts loc.full_name
    puts "FAILED Geocode record #" + loc.id.to_s
  end
  sleep 0.5 # because Google enforces a per-second limit on location api requests
end
