class SiteFeedbacksController < ApplicationController
  before_action :set_site_feedback, only: [:show, :edit, :update, :destroy]
  before_filter :ensure_admin, except: [:new, :create, :edit]

  respond_to :html

  def index
    @site_feedbacks = SiteFeedback.all.order(:created_at).paginate(:page => params[:page], :per_page => 50)
    respond_with(@site_feedbacks)
  end

  def new
    @site_feedback = SiteFeedback.new
    respond_with(@site_feedback)
  end

  def edit
  end

  def create
    @site_feedback = SiteFeedback.new(site_feedback_params)
    if @site_feedback.save
      flash[:message] = "Your feedback has been received. Your assistance in helping to improve this site is greatly appreciated."
      redirect_to root_path
    else
      render :edit
    end
  end

  def download_site_feedback
    respond_to do |format|
      format.html
      format.csv { render csv: SiteFeedback.all }
    end
  end

  private

  def set_site_feedback
    @site_feedback = SiteFeedback.find(params[:id])
  end

  def site_feedback_params
    params.require(:site_feedback).permit(:description, :how_to_replicate, :url, :name, :email, :reviewer_comment)
  end

  def ensure_admin
    unless current_user && current_user.va_admin?
      flash[:error] = "You are not authorized access that page."
      redirect_to root_path
    end
  end

end
