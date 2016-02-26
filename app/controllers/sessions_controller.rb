class SessionsController < ApplicationController
  def set_skills_translator_session_var
    session[:skills_translator]=true
    render json: nil, status: :ok
  end
end
