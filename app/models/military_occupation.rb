class MilitaryOccupation < ActiveRecord::Base

  validates_uniqueness_of :code, scope: [:service, :active, :category]
  validates :service, inclusion: {in: ['Army', 'Navy', 'Marine Corps', 'Coast Guard', 'Air Force', 'DEFAULT'],
    message: "%{value} must be one of the following: Army, Navy, Marine Corps, Coast Guard, or Air Force"}

  def self.find_by_moc_and_branch(moc, branch)
    matches = MilitaryOccupation.where(
      'lower(code) = ? and lower(service) = ?', moc.downcase, branch.downcase)
    return matches.length > 1 ? matches.where(active: true) : matches
  end

  def self.find_by_moc_branch_status_category(moc, branch, status, category)
    matches = MilitaryOccupation.where(
      'lower(code) = ? and lower(service) = ? and active = ? and category = ?', moc.downcase, branch.downcase, status, category)
    return matches
  end

  def self.default_occupation(moc, branch)
    default = MilitaryOccupation.find_by_moc_and_branch('DEFAULT', 'DEFAULT').
                                 select(:id, :title, :category, :service,  \
                                        'upper(code) as moc',
                                        'lower(service) as branch')[0]
    default.service = branch.capitalize
    default.moc = moc.upcase
    default
  end
end
