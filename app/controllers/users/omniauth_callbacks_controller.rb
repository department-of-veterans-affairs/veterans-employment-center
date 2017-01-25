class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.find_for_google_oauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      redirect_to commitments_path
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      flash[:warn] = "OAuth failed with Google"
      redirect_to commitments_path
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
      redirect_to commitments_path
    else
      session["devise.linkedin_data"] = request.env["omniauth.auth"]
      flash[:warn] = "OAuth failed with LinkedIn"
      Rails.logger.info "OAuth Failure (LinkedIn)! auth: #{auth.inspect}"
      redirect_to commitments_path
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
end
