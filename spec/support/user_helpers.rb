def employer_user
  user = create :user, email: "guy@employer.com"
  user.provider = "google_oauth2"
  user.build_employer(street_address: "123 Main St", city: "Anywhere", state: "MO", zip: "44444", phone: "222-333-4444", commit_to_hire: 1, ein: rand(999999999).to_s.center(9, rand(9).to_s))
  user.save
  user
end

def sign_in_as(user)
  login_as user, scope: :user
end

def sign_in_as_admin
  admin_user = create :user, email: 'test@va.gov', password: '12345678', va_admin: true
  sign_in_as(admin_user)
end

  
