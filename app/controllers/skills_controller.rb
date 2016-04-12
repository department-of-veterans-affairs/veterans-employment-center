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
    query = "source in ('linkedin', 'bayes') and name ilike '#{params['prefix']}%'"
    render json: Skill.where(query).select(:id, :name).to_json
  end

  def get_common_skills
    render json: Skill.where(is_common: true).select(:id, :name).to_json
  end

  def suggest
    # TODO: do this at load time, not on every query
    # Load the current skills translator model
    model_id = ENV["SKILLS_TRANSLATOR_MODEL_ID"] || 1
    model = SkillsTranslatorModel.find_by(id: model_id)
    if model.nil?
      logger.error "Missing or bad ENV variable SKILLS_TRANSLATOR_MODEL_ID (#{model_id})"
      head 500
      return
    end

    # Validate query
    moc = params[:moc] || "DEFAULT"
    branch = params[:branch] || "DEFAULT"
    status = params[:status] || "true"
    category = params[:category] || "Enlisted"

    query_str = "MOC #{moc} with the #{branch.split.map(&:capitalize).join(' ')}"

    # Find matching unique MOC
    occupation_matches = MilitaryOccupation.find_by_moc_branch_status_category(moc, branch, status, category)
    if occupation_matches.length == 0
      military_occupation = MilitaryOccupation.default_occupation(moc, branch)
    elsif occupation_matches.length > 1
      return_error "We found more than one occupation for #{query_str}"
      return
    else
      military_occupation = occupation_matches.select(:id, :title, :category,
        :service, 'upper(code) as moc', 'lower(service) as branch')[0]
    end

    skill_rows = SkillsForMilitaryOccupation.get_skills(model, military_occupation)

    # If no results are returned, use the default results.
    if skill_rows.empty?
      # Get the skills for the default occupation
      skill_rows = SkillsForMilitaryOccupation.get_skills(model,
        MilitaryOccupation.default_occupation(moc, branch))
    end

    skills = skill_rows.as_json

    # Generate a UUID for the query
    query_uuid = SecureRandom.uuid

    # Create a SkillsTranslatorEvent object with the query info
    session = SkillsTranslatorEvent.create(
      query_uuid: query_uuid,
      event_type: :QUERY,
      event_number: 0,
      payload: {model_id: model.id, branch: branch, moc: moc}.to_json)

    num_skills_to_return = (ENV["SKILLS_TRANSLATOR_NUM_SKILLS_TO_RETURN"] || 200).to_i
    skills = randomize_skills(skills, num_skills_to_return)
    skills = skills[0, num_skills_to_return]
    if ENV["SKILLS_TRANSLATOR_DEBUG"].to_i == 1
      skills.each do |s|
        rel = s["relevance"].present? ? s["relevance"].round(4) : "unknown"
        s["name"] = "#{s["name"]} (#{rel})"
      end
    end

    # Construct the return json
    render json: {
      military_occupation: military_occupation,
      skills: skills,
      query_uuid: query_uuid
    }
  end

  def save_event
    event = SkillsTranslatorEvent.create(
      query_uuid: params[:query_uuid],
      event_type: params[:event_type],
      event_number: params[:event_number],
      skill_id: params[:skill_id],
      payload: params[:payload].to_json,
      browser_timestamp: params[:timestamp],
      page: params[:page],
      shown_skills: params[:shown_skills].to_json,
    )
    head 200
    return
  end

  private

    def randomize_skills(original_skills, num_skills_to_return)
      # Returns a shuffled version of 'skills' weighting by relevance
      # and including some noise, tunable by environment variables

      randomizer_strength = (ENV["SKILLS_TRANSLATOR_RANDOMIZER_STRENGTH"] || 0.2).to_f
      # Clamp to [0, 1]
      randomizer_strength = [0.0, [randomizer_strength, 1.0].min].max
      if randomizer_strength == 0
        # No randomization
        return original_skills
      end

      randomized_skills = randomize_order_weighted_by_relevance(
        original_skills, randomizer_strength, num_skills_to_return)
      randomized_skills = replace_skills_at_random(
        randomized_skills, randomizer_strength, num_skills_to_return)

      return randomized_skills
    end

    def randomize_order_weighted_by_relevance(skills, strength, num_skills_to_return)
      # Randomly sort elements, weighted by their relevance.
      # We weight by the skill relevance to a power (relevance exponent)
      # to tweak the amount of randomization. A power of 0.0
      # is complete randomness, while a large value (e.g. 10.0)
      # has almost no randomness (and returns in relevance order).
      relevance_exponent = (1 - strength) * 10
      max_relevance = (skills.map {|s| s["relevance"]}).max
      total_weight = 0.0
      skills.each do |s|
        s["weight"] = (s["relevance"] / max_relevance) ** relevance_exponent
        total_weight += s["weight"]
      end
      reordered_skills = []
      n = [skills.length, num_skills_to_return].min
      while true do
        r = rand * total_weight
        skills.each_with_index do |s, index|
          if r < s["weight"] or index == skills.length - 1
            reordered_skills << skills.delete(s)
            total_weight -= s["weight"]
            break
          end
          r -= s["weight"]
        end
        break if reordered_skills.length == n
      end
      reordered_skills.each {|s| s.delete "weight"}
      return reordered_skills
    end

    def replace_skills_at_random(skills, strength, num_skills_to_return)
      # To ensure that we occasionally test all skills, no matter how
      # irrelevant we thought they were, we randomly replace a few
      # of our "relevant" skills with totally random skills.
      percentage = 5 + strength * 15  # Replace 5-20%
      num_to_replace = (num_skills_to_return * percentage / 100).round

      # Use only the linkedin and Bayes Impact generated corpus, so we don't
      # surface bizarre custom skills people have entered.
      random_skills = Skill.where("source in ('bayes', 'linkedin')").limit(
        num_to_replace).order("RANDOM()").to_a

      # if there are less available rnadom skills than the number we need to
      # replace, just bail out and return the unchanged skills
      if random_skills.length < num_to_replace
        return skills
      end

      random_indices = (0..(skills.length-1)).to_a.sample(num_to_replace)
      random_indices.each do |idx|
        skills[idx] = random_skills.pop
      end
      return skills
    end

    def return_error(message)
      logger.error message
      render json: {error: message}.to_json, status: 500
    end
end
