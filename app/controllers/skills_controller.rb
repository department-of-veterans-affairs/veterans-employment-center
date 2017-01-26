class SkillsController < ApplicationController

  # makes debugging using Postman easier. And I don't see why we use CSRF for this form
  skip_before_action :verify_authenticity_token

  def index
  end

  def add_skill
    return render json: {
      error: "name parameter missing"
    }.to_json if params[:name].blank?
    skill = Skill.where('lower(name) = ?', params[:name].downcase).take
    skill ||= Skill.create(name: params[:name], source: 'manual')
    render json: skill.to_json(only: [:id, :name])
  end

  def get_skills
    query = ["source in ('linkedin') and name ilike ?", "#{params[:prefix]}%"]
    @skills = Skill.where(query)
    render json: @skills.select(:id, :name).to_json
  end
end
