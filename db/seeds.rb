# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require File.expand_path('../seed/data_importer', __FILE__)

tables = [
  "job_title_military_occupations",
  "military_occupations",
  "skills_for_military_occupations",
  "job_titles",
  "deprecated_job_skills",
  "deprecated_job_skill_matches",]

puts "Truncating " + tables.join(', ') + "..." unless Rails.env == 'test'
ActiveRecord::Base.connection.execute("TRUNCATE "+ tables.join(',') + " RESTART IDENTITY;")

puts "Importing all jobs and skills ..." unless Rails.env == 'test'
DataImporter.import_ONET_job_skills
DataImporter.import_federal_jobs
DataImporter.import_ONET_jobs
puts "Finished importing all jobs and skills" unless Rails.env == 'test'

puts "Importing all military occupations ..." unless Rails.env == 'test'
DataImporter.import_all_mos
puts "Finished importing all military occupations" unless Rails.env == 'test'

puts "Getting military career -> job title link info" unless Rails.env == "test"
DataImporter.link_military_careers

puts "Importing federal XWALK data ..." unless Rails.env == 'test'
puts "This will take a couple of minutes." unless Rails.env == 'test'
DataImporter.connect_federal_jobs_to_mocs
puts "Finished importing XWALK data" unless Rails.env == 'test'

puts "All data imported" unless Rails.env == 'test'
