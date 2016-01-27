class EmployersController < ApplicationController
  before_action :set_employer, only: [:show, :edit, :update, :destroy, :account]
  before_filter :authenticate_user!, except: [:commitments] #this is the Devise authentication filter
  before_filter :ensure_admin, except: [:edit, :update, :show, :commitments, :account]
  before_filter :correct_user, only: [:edit, :update, :account]
  before_filter :clean_params, only: [:create, :update]
  
  def index
    @employers = EmployerReport.new(params, self)
    @search = @employers.searchform
    respond_to do |format|
      format.html
      format.json {render json: @employers}
    end
  end

  def show
  end
  
  def download_employers
    respond_to do |format|
      format.html
      format.csv do
        self.response_body = StreamCSV.new('employers.csv', response) do |csv|
          EmployerReport.new.to_csv(csv)
        end
          
      end
    end
  end

  def download_veterans
    respond_to do |format|
      format.html
      format.csv { render csv: Veteran.where.not(:user_id => nil) }
    end
  end

  def commitments
    @commitment_report = CommitmentReport.new(params, self)
    respond_to do |format|
      format.html
      format.csv  do
        self.response_body = StreamCSV.new('commitment_report', response) do |csv|
          @commitment_report.to_csv(csv)
        end
      end
      format.json do
        
        render json: @commitment_report
      end
    end
  end

  def edit
  end

  def create
    @employer = Employer.new(employer_params)
    if @employer.save
      redirect_to @employer, notice: 'Employer was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    params[:employer][:commitment_categories].reject!(&:empty?) unless params[:employer][:commitment_categories].nil?
    if (@employer.approved != params[:employer][:approved]) && (params[:employer][:approved] == "true")
      @employer.update_attributes(:approved_by => current_user.email, :approved_on => Time.current.to_date)
    end
    if @employer.update_attributes(employer_params)
      redirect_to :back, notice: "#{@employer.company_name} was successfully updated."
    else
      render action: 'edit'
    end
  end

  def destroy
    @employer.destroy
    redirect_to employers_url
  end


  private
    
  def set_employer
    @employer = Employer.find(params[:id])
  end

  def employer_params
    if current_user.va_admin?
      params.require(:employer).permit(permitted_params + admin_params)
    else
      params.require(:employer).permit(permitted_params)
    end
  end
  
  def permitted_params
    [:company_name, :ein, :commit_to_hire, :commit_hired, :commit_date, :note, :website, :location, :phone, :street_address, :city, :state, :zip, :poc_name, :poc_email,
     {:commitment_categories => []}, :job_postings_url]
  end
  
  def admin_params
    [:approved, :admin_notes]
  end
  
  def correct_user
    unless current_user == @employer.user || current_user.va_admin?
      flash[:warn] = "You are not authorized to edit this profile."
      redirect_to root_path
    end
  end

  def ensure_admin
    unless current_user.va_admin?
      flash[:error] = "unauthorized access"
      redirect_to root_path
    end
  end
  
  def clean_params
    clean_date_params(params)
  end
end
