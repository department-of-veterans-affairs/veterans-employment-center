class SkillsTranslatorEvent < ActiveRecord::Base
  extend Enumerize

  enumerize :event_type, in: [:QUERY, :SHOWED_SKILLS, :SKILL_SELECTED, :SKILL_REMOVED,
                              :BUILD_RESUME, :START_OVER, :SKILL_ADDED, :VETERAN_CREATED ]
end
