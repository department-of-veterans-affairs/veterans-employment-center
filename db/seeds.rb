# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require File.expand_path('../seed/data_importer', __FILE__)

tables = [
  "military_occupations",
  "skills_for_military_occupations",]

puts "Truncating " + tables.join(', ') + "..." unless Rails.env == 'test'
ActiveRecord::Base.connection.execute("TRUNCATE "+ tables.join(',') + " RESTART IDENTITY;")

puts "Importing all military occupations ..." unless Rails.env == 'test'
DataImporter.import_all_mos
puts "Finished importing all military occupations" unless Rails.env == 'test'

puts "Importing all skills ..." unless Rails.env == 'test'
Rake::Task['db:seed_skills'].execute
puts "Finished importing all skills" unless Rails.env == 'test'

puts "Creating initial MOC skills ..." unless Rails.env == 'test'
Rake::Task['db:create_initial_model'].execute
puts "Finished creating initial MOC skills" unless Rails.env == 'test'

puts "All data imported" unless Rails.env == 'test'
