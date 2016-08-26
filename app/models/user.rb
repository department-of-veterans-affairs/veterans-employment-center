class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :trackable, :omniauthable , omniauth_providers: [:google_oauth2,:linkedin, :saml, :linkedin_resume]
  validates_presence_of :email
  validates_uniqueness_of :email, scope: :provider
  has_one :employer
  has_one :veteran

  def self.find_for_google_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.build_employer
    end
  end

  def self.find_for_linkedin_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.build_employer
    end
  end

  def self.find_for_saml(auth)
    uid = auth.extra.raw_info["dodEdiPnId"]
    where_hash = {provider: "SAML", uid: uid}
    where(where_hash).first_or_create do |user|
      user.provider = "SAML"
      user.uid = uid
      user.email = "#{uid}@dslogon.dod.mil"
      user.password = Devise.friendly_token[0,20]
    end
  end

  def is_approved_employer?
    is_employer? && employer.approved?
  end

  def is_employer?
    if ["linkedin", "google_oauth2"].include?(self.provider)
      return true
    else
      return false
    end
  end

  def is_veteran?
    if self.provider == "SAML"
      return true
    else
      return false
    end
  end
end
