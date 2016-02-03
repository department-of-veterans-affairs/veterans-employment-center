
class EventBuilder
  def initialize(model, moc, query_uuid, skills)
    @model = model
    @moc = moc
    @event_counter = 0
    @query_uuid = query_uuid
    @skills = Hash[skills.map do |skill|
      [skill.id, {id: skill.id, page: 0, selected: false}]
    end]

    # create initial query event
    SkillsTranslatorEvent.create(
      query_uuid: @query_uuid,
      event_type: 'QUERY',
      event_number: @event_counter,
      payload: {moc: @moc.code, branch:@moc.service, model_id: @model.id}.to_json
    )
    @event_counter += 1

    # create show_skills event
    SkillsTranslatorEvent.create(
      query_uuid: @query_uuid,
      event_type: 'SHOWED_SKILLS',
      event_number: @event_counter,
      payload: @skills.values.map { |e| e[:id] },
      page: 0
    )
    @event_counter += 1
  end

  def select_skill(skill_id)
    @skills[skill_id][:selected] = true
    SkillsTranslatorEvent.create(
      query_uuid: @query_uuid,
      event_type: 'SKILL_SELECTED',
      event_number: @event_counter,
      skill_id: skill_id,
      page: 0,
      shown_skills: @skills.values.to_json,
    )
    @event_counter += 1
  end
end


skill_descriptions = [
  {initial: 1, target: 0},
  {initial: 0.5, target: 0},
  {initial: 0, target: 0},
  {initial: 1, target: 0.5},
  {initial: 0.5, target: 0.5},
  {initial: 0, target: 0.5},
  {initial: 1, target: 1},
  {initial: 0.5, target: 1},
  {initial: 0, target: 1},
  {initial: 0, target: 0.25}
]

N_QUERIES = 100

namespace :db do

  desc 'Seed with a fake model and click data.'
  task fictitious_click_data: :environment do

    puts ">>> creating toy dataset for #{N_QUERIES} queries"
    model = SkillsTranslatorModel.find_or_create_by(description: "click data fake model")
    model.update_attributes(last_processed_event_timestamp: Time.now)
    moc = MilitaryOccupation.find_or_create_by(service: 'Army', code: 'FAKE_MOC')

    # create skills and initial MOC -> Skill model
    skill_descriptions.each do |desc|
      name = "initial: #{desc[:initial]} - target: #{desc[:target]}"
      desc[:skill] = Skill.find_or_create_by(name: name, source: 'fake_skills')
      SkillsForMilitaryOccupation.find_or_create_by(
        skills_translator_model: model,
        military_occupation: moc,
        skill: desc[:skill],
        relevance: desc[:initial]
      )
    end

    # generate queries
    N_QUERIES.times do |query_uuid|

      skills = skill_descriptions.map { |e| e[:skill] }
      eb = EventBuilder.new(model, moc, "fake_query_#{query_uuid}", skills)

      skill_descriptions.each do |desc|
        eb.select_skill(desc[:skill].id) if Random.rand < desc[:target]
      end
    end
    puts ">>> done"
  end
end
