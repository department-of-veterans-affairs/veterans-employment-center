class EducationLevel
  LEVELS = ["Some High School Coursework",
  "High School or equivalent",
  "Technical or Occupational Certificate",
  "Associate's Degree",
  "Some College Coursework Completed",
  "Bachelor's Degree",
  "Master's Degree","Doctorate",
  "Professional"]

  def self.at_least(text_desc)
    match_index = LEVELS.index(text_desc)
    match_index ? LEVELS[match_index,LEVELS.size-1] : LEVELS
  end
end
