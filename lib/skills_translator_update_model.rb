
module SkillsTranslatorUpdateModel
  class RelevanceUpdate

    def initialize(from_model_id)
      @model = SkillsTranslatorModel.find(from_model_id.to_i)
      puts "The current model id is #{@model.id}, '#{@model.description}'"

      @new_clicks_imps = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [0.0, 0.0] }}
      @last_processed_event = @model.last_processed_event_timestamp.nil? ? Time.new(1985) : @model.last_processed_event_timestamp
      @now = Time.now

      if load_new_events
        load_unchanged_relevance_impressions
        update_relevance_impressions
      else
        puts "There are no new events since the last update."
      end

    end

    def load_new_events
      new_queries = SkillsTranslatorEvent.where(created_at: @last_processed_event..@now).where(event_type: 'QUERY')
      shown_skills = SkillsTranslatorEvent.where(created_at: @last_processed_event..@now).order(query_uuid: :desc, event_number: :desc).select("DISTINCT ON (query_uuid) query_uuid, shown_skills")

      new_queries_count = new_queries.count
      puts "There are #{new_queries_count} new queries since the last model."

      return false if new_queries_count == 0
      puts "Now loading new click data from db."

      new_queries.find_each do |query|

        event = shown_skills.find_by(query_uuid: query.query_uuid)
        next if event.nil?

        query_params = JSON.parse(query.payload)
        shown_skills_array = JSON.parse(event.shown_skills)
        moc = MilitaryOccupation.find_by_moc_and_branch(query_params["moc"], query_params["branch"]).first

        shown_skills_array.each {|shown_skill|
          count_skill_impression(moc.id, shown_skill["id"], shown_skill["page"], shown_skill["selected"])
        }
      end
      new_queries_count > 0
    end

    def load_unchanged_relevance_impressions
      puts "Now loading the previous model relevance and impressions"
      new_model_desc = "created by rake db:update_skill_translator from model #{@model.id}"
      @new_model = SkillsTranslatorModel.create(description: new_model_desc,
                                                last_processed_event_timestamp: @now)

      query = "INSERT INTO skills_for_military_occupations (military_occupation_id, skill_id, relevance, impressions, skills_translator_model_id, created_at, updated_at)
       (SELECT sk.military_occupation_id, sk.skill_id, sk.relevance, sk.impressions, #{@new_model.id}, now(), now()
       FROM skills_for_military_occupations sk
       WHERE skills_translator_model_id = #{@model.id})"
      connection = ActiveRecord::Base.connection
      connection.execute(query)
    end

    def update_relevance_impressions
      puts "Now updating the model. The new translator model id is #{@new_model.id}."
      @new_clicks_imps.each do |mocid, skill_hash|
        skill_hash.each do |skillid, click_imp|
          moc_skill = load_current_relevance(mocid, skillid)

          new_impression = moc_skill.impressions + click_imp[1]
          new_clicks = (moc_skill.relevance * moc_skill.impressions + click_imp[0])
          new_relevance = new_clicks / new_impression

          moc_skill.update_attributes(relevance: new_relevance,
                                      impressions: new_impression)
          moc_skill.save!
        end
      end
    end

    private

    def count_skill_impression(mocid, skillid, page, selected)
      clicked = (selected ? 1 : 0)

      prev_clicks, prev_impressions = @new_clicks_imps[mocid][skillid] # Will just be 0,0 for new skills
      @new_clicks_imps[mocid][skillid] = [prev_clicks + clicked, prev_impressions + impression(page)]

    end

    def impression(page_number)
      return 1
    end

    def load_current_relevance(mocid, skillid)
      rec = SkillsForMilitaryOccupation.find_by(military_occupation_id: mocid,
                                                skill_id: skillid,
                                                skills_translator_model_id: @new_model.id)
      if rec.nil?
        rec = SkillsForMilitaryOccupation.new(military_occupation_id: mocid, skill_id: skillid,
                                              skills_translator_model_id: @new_model.id,
                                              relevance: 0, impressions: 0)
      end
      return rec
    end
  end
end
