require "#{Rails.root}/lib/skills_translator_update_model"
include SkillsTranslatorUpdateModel

namespace :db do
  desc 'Updates skills relevance and skills translator model number.'
  task :update_skills_translator, [:from_model_id] => :environment do |t, args|
    args.with_defaults(:from_model_id => ENV["SKILLS_TRANSLATOR_MODEL_ID"])
    from_model_id = args[:from_model_id]
    if not from_model_id.present?
      fail %q(You must call this task with the target model id
        set as an argument, e.g. rake db:update_skills_translator[42],
        OR have the SKILLS_TRANSLATOR_MODEL_ID environment variable set.)
    end
    if from_model_id.to_i.to_s != from_model_id
      fail %Q(Specified skills translator model id "#{from_model_id}"" is not an integer)
    end
    puts "Updating model #{from_model_id}"
    ru = RelevanceUpdate.new(from_model_id.to_i)
  end
end
