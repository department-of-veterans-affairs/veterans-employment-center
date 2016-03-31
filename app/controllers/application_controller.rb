class ApplicationController < ActionController::Base
  protect_from_forgery #had to comment out 'with: :exception' because of an InvalidAuthenticityToken issue
  #see: https://github.com/plataformatec/devise/issues/2586
  before_filter :check_maintenance_page

  # Override default devise path for employers who have not added a Company name and EIN to their profiles yet.
  def after_sign_in_path_for(resource)
    if current_user.is_employer?
      if current_user.employer != nil && current_user.employer.company_name.blank?
        flash[:notice] = "Welcome!"
        edit_employer_path(current_user.employer)
      else
        veterans_path
      end
    elsif current_user.is_veteran?
      if !current_user.veteran.nil?
        edit_veteran_path(current_user.veteran)
      else
        flash[:notice] = "Welcome!"
        root_path
      end
    elsif current_user.va_admin
      employers_path
    else
      root_path
    end
  end

  def after_sign_out_path_for(resource)
    # right now we don't allow veterans to sign out...if we do, this would need to be updated
    employer_home_path
  end

  protected

  def clean_date_params(params)
    params.each do |key, value|
      if value.is_a? Hash
        clean_date_params(value)
      elsif value.is_a?(String) && !value.blank?
        params[key] = "#{value[6..10]}-#{value[0..1]}-#{value[3..4]}}" if key.end_with?('date') || key.end_with?('_on')
      end
    end
  end

  # if the VEC_MAINTENANCE_UNDERWAY variable is present, redirect to a maintenance page
  def check_maintenance_page
    if ENV.key? 'VEC_MAINTENANCE_UNDERWAY'
      redirect_to "/maintenance.html"
    end
  end
end
