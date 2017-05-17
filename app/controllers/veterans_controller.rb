class VeteransController < ApplicationController
  before_action :set_veteran, only: [:show, :edit, :update, :destroy, :favorite, :word]
  before_filter :ensure_employer, only: [:favorites, :favorite]
  before_filter :ensure_employer_or_admin, only: [:index]
  before_filter :validate_veteran, only: [:edit, :destroy, :update, :show, :word]
  before_filter :clean_params, only: [:create, :update]
  before_filter :ensure_admin, only: [:download_all_veterans]

  MULTIPLE_TERM_PATTERN = /\s*,\s*/i
  KEYWORD_FIELD_NAME = 'searchable_summary_cont'

  def index
  end

  def show
  end

  def word
      @for_fed_employment = params[:fed]=="true"
      respond_to do |format|
        format.docx do
          response.headers['Content-Disposition'] = 'attachment; filename="resume.doc"'
          render content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", layout: 'word'
        end
      end
    end

  def favorite
    type = params[:type]
    if type == "favorite"
      current_user.employer.favorites << @veteran
      redirect_to :back
    elsif type == "unfavorite"
      current_user.employer.favorites.delete(@veteran)
      redirect_to :back
    else
      redirect_to :back, notice: 'Nothing.'
    end
  end

  def favorites
    @veterans = current_user.employer.favorites
  end


  # This route is to initialize a new veteran (from the skill-translator or linkedin)
  # and then display this veteran in the resume builder. A veteran object is only
  # create in memory but NOT SAVED to the database (not yet valid, name and email missing).
  # The create method finally creates a new veteran entry in the database.
  def new
    @veteran = session[:linkedin_profile] ? Veteran.new_from_linkedin_profile(session[:linkedin_profile]) : Veteran.new
    @veteran.skills << Skill.find(params[:skills]) if params[:skills].present?
    return if params['moc'].blank? || params['branch'].blank?
    occupation = MilitaryOccupation.find_by_moc_branch_status_category(params[:moc], params['branch'], params['status'], params['category']).first()
    if occupation
      @veteran.experiences << Experience.new({
        moc: occupation.code,
        organization: occupation.service,
        job_title: occupation.title,
        description: occupation.description.gsub(/<\/?p>/i, "\n"),
        experience_type: 'military',
      })
    end
  end

  def edit
  end

  # If an unauthenticated Veteran creates a resume, the veteran_id is saved to a cookie. If they proceed to log in, the cookie links their User to their Veteran.
  def create
    @veteran = Veteran.new(veteran_params)
    if user_signed_in?
      @veteran.update_attributes(user_id: current_user.id) if current_user.veteran.nil?
    else
      request.session[:init] = true
      @veteran.update_attributes(session_id: request.session_options[:id])
    end
    if @veteran.save
      last_event = SkillsTranslatorEvent.where(query_uuid: cookies[:query_uuid])
                                        .order('event_number').last
      SkillsTranslatorEvent.create(
        query_uuid: cookies[:query_uuid],
        event_type: 'VETERAN_CREATED',
        event_number: last_event.event_number + 1,
        payload: {veteran_id: @veteran.id}.to_json) if not last_event.nil?

      cookies[:veteran_id] = @veteran.id
      redirect_to @veteran
    else
      render action: 'new'
    end
  end

  def update
    if @veteran.user_id.nil?
      @veteran.update_attributes(user_id: current_user.id) if user_signed_in? && current_user.veteran.nil?
    end
    if !veteran_params["locations_attributes"].blank?
      @veteran.update_location_attributes(veteran_params["locations_attributes"])
    end
    if @veteran.update(veteran_params)
      redirect_to @veteran, notice: 'Veteran was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @veteran.destroy
    redirect_to root_path
  end

  private

  def set_veteran
    @veteran = Veteran.find(params[:id])
  end

  def veteran_params
    params.require(:veteran).permit(
      :name,
      :email,
      :objective,
      :session_id,
      :visible,
      :availability_date,
      references_attributes: [:name, :email, :job_title, :id, :veteran_id, :_destroy],
      affiliations_attributes: [:job_title, :organization, :id, :veteran_id, :_destroy],
      awards_attributes: [:title, :veteran_id, :organization, :date, :id, :_destroy],
      experiences_attributes: [:job_title, :organization, :experience_type, :start_date, :end_date, :hours, :educational_organization, :credential_type, :credential_topic, :description, :veteran_id, :moc, :duty_station, :rank, :id, :_destroy],
      desiredPosition: [],
      :skill_ids => [],
      status_categories: [],
      locations_attributes: [:id, :veteran_id, :location_type, :full_name, :city, :state, :country, :lat, :lng, :zip, :include_radius, :radius, :_destroy],
    )
  end

  def ensure_employer
    unless !current_user.nil? && current_user.is_employer?
      flash[:error] = "Only signed in employers can view this page"
      redirect_to new_user_session_path
    end
  end

  def ensure_admin
    unless current_user.va_admin?
      flash[:error] = "unauthorized access"
      redirect_to root_path
    end
  end

  def ensure_employer_or_admin
    unless !current_user.nil? && (current_user.is_employer? || current_user.va_admin?)
      flash[:error] = "Only signed in employers or administrators can view this page"
      redirect_to new_user_session_path
    end
  end


  def validate_veteran_or_employer
    if current_user && current_user.is_employer?
      return
    elsif user_owns_veteran?
      return
    else
      redirect_to_home_page
    end
  end

  def validate_veteran
    redirect_to_home_page unless user_owns_veteran?
  end

  def user_owns_veteran?
    session_id = request.session_options[:id]
    if session_id && @veteran.session_id == session_id
      true
    elsif !current_user.nil? && current_user == @veteran.user
      true
    else
      false
    end
  end

  def redirect_to_home_page
    flash[:error] = "You do not have access to that content."
    redirect_to root_path
  end

  def clean_params
    clean_blank_params
    clean_date_params(params)
  end

  def clean_blank_params
## TODO: REINSTATE THE BELOW IN TERMS OF NEW MODEL/PARAMS
##    params[:veteran][:desiredLocation].reject!(&:empty?)
    params[:veteran][:status_categories].reject!(&:empty?) unless params[:veteran][:status_categories].nil?
  end

  # Build complex Ransack search group that allows AND operator in keywords.
  #
  # For example, if the keyword is "accounting AND infantry", the built search
  # group should be "if any of the keyword fields contains accounting AND if
  # any of those also contains infantry".
  def build_search(query, params_hash=nil)
    params_hash ||= {}
    # If there are no params or if keyword search is not used, just build a
    # plain Ransack search.
    keyword_query_str = params_hash[KEYWORD_FIELD_NAME].presence
    return query.search(params_hash) unless keyword_query_str

    # Rip the keywords on the AND pattern, do a pg_search search for
    # keywords and ransack for the rest

    keywords = keyword_query_str.split(MULTIPLE_TERM_PATTERN).map{|k| k.gsub(/\s/, '+')}.join(' ')

    if params_hash['m'].downcase == 'or'
      base = query.keyword_search_any(keywords)
    else
      base = query.keyword_search_all(keywords)
    end
    return base.search(params_hash.except(KEYWORD_FIELD_NAME, 'm'))
  end

end
