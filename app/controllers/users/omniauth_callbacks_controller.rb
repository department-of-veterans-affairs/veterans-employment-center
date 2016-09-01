class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token, only: [:saml]

  def google_oauth2
    @user = User.find_for_google_oauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      redirect_to employer_home_path
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      flash[:warn] = "OAuth failed with Google"
      redirect_to employer_home_path
    end
  end

  def linkedin
    auth = request.env["omniauth.auth"]
    @user = User.find_for_linkedin_oauth(auth)
    if @user.persisted? == false
      @user = User.find_by_provider_and_email("linkedin", auth.info.email)
      @user.update_attributes(uid: auth.uid) if @user && @user.persisted?
    end
    if @user && @user.persisted?
      sign_in @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "LinkedIn") if is_navigational_format?
      redirect_to employer_home_path
    else
      session["devise.linkedin_data"] = request.env["omniauth.auth"]
      flash[:warn] = "OAuth failed with LinkedIn"
      Rails.logger.info "OAuth Failure (LinkedIn)! auth: #{auth.inspect}"
      redirect_to employer_home_path
    end
  end

  def linkedin_resume
    auth = request.env["omniauth.auth"]
    client = LinkedIn::Client.new
    client.authorize_from_access(auth.extra.access_token.token, auth.extra.access_token.secret)
    linkedin_profile = client.profile(fields: %w(email-address	first-name last-name location positions educations skills volunteer honors-awards recommendations-received))
    session[:linkedin_profile] = linkedin_profile
    flash.notice = "Your resume has been prefilled with your LinkedIn information."
    redirect_to resume_builder_path
  end

  def saml
    @user = User.find_for_saml(request.env["omniauth.auth"])
    if @user.persisted?
      @user.veteran = Veteran.find(cookies[:veteran_id]) if @user.veteran.nil? and cookies[:veteran_id]
      if !@user.veteran.nil?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "DS Logon") if is_navigational_format?
      else
        sign_in @user, event: :authentication
        set_flash_message(:notice, :success, kind: "DS Logon") if is_navigational_format?
        redirect_to new_veteran_path
      end
    else
      session["devise.saml_data"] = request.env["omniauth.auth"]
      flash[:warn] = "SAML failed"
      redirect_to root_path
    end
  end

end
