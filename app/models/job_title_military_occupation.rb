class JobTitleMilitaryOccupation < ActiveRecord::Base
  belongs_to :job_title
  belongs_to :military_occupations

  def self.filter_by_pay_grade(grade)
    paygrades = Rank.all
    if grade.presence
      if place = paygrades.index(grade.to_s.gsub(/[\W]/, ''))
        return where(pay_grade: [nil] + paygrades[0..place])
      end
    end
    where(nil)
  end
end