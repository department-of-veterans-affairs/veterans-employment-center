# coding: utf-8
require 'rails_helper'

feature 'User is reading the Skills Translator page' do
  before do
    @moc = create(:military_occupation)
    @default_moc = create(:default_military_occupation)
    @model = SkillsTranslatorModel.create(
        description: "Fake model")
    ENV['SKILLS_TRANSLATOR_MODEL_ID'] = @model.id.to_s
    ENV['SKILLS_TRANSLATOR_PERCENT_SKILLS_RANDOM'] = '0'
    ENV['SKILLS_TRANSLATOR_RELEVANCE_EXPONENT'] = '-1'
    10.times do |i|
        sk = Skill.create(name: "Fake Skill #{i+1}", source: "Fake Source")
        rel = SkillsForMilitaryOccupation.create(
            skills_translator_model_id: @model.id,
            military_occupation_id: @moc.id,
            skill_id: sk.id,
            relevance: (10 - i).to_f / 10)
        rel = SkillsForMilitaryOccupation.create(
            skills_translator_model_id: @model.id,
            military_occupation_id: @default_moc.id,
            skill_id: sk.id,
            relevance: (10 - i).to_f / 10)
    end

    visit skills_translator_path
  end

  def fill_and_submit_form
    select 'Army', from: 'military_position_branch'
    fill_in 'military_position_code', with: @moc.code
    click_button 'Translate'
  end

  scenario 'Skills and import button should only appear after searching', js: true do
    page.assert_selector('#pill-box', count: 0)
    page.assert_selector('#importButton', count: 0)
    expect(page).to have_no_content 'Fake Skill 1'
    fill_and_submit_form
    page.assert_selector('#pill-box', count: 1)
    page.assert_selector('#importButton', count: 1)
    expect(page).to have_content 'Fake Skill 1'
  end

  scenario 'Non-existent MOC code shows default skills', js: true do
    select 'Army', from: 'military_position_branch'
    fill_in 'military_position_code', with: "foobarbaz"

    click_button 'Translate'

    page.assert_selector('#pill-box', count: 1)
    page.assert_selector('#importButton', count: 1)
    expect(page).to have_content 'Fake Skill 1'
  end

  scenario 'Translate when empty shows results', js: true do
    click_button 'Translate'
    page.assert_selector('#pill-box', count: 1)
    page.assert_selector('#importButton', count: 1)
    expect(page).to have_content 'Fake Skill 1'
  end

  scenario 'Translate with just a branch shows results', js: true do
    select 'Army', from: 'military_position_branch'
    click_button 'Translate'
    page.assert_selector('#pill-box', count: 1)
    page.assert_selector('#importButton', count: 1)
    expect(page).to have_content 'Fake Skill 1'
  end

  scenario 'Translate with no branch and an invalid MOC shows results', js: true do
    fill_in 'military_position_code', with: "this definitely does not exist"
    click_button 'Translate'
    page.assert_selector('#pill-box', count: 1)
    page.assert_selector('#importButton', count: 1)
    expect(page).to have_content 'Fake Skill 1'
  end

  scenario 'Matching MOC returns option to generate resume; resume has auto-filled MOC, branch, title, and description, and rank ', js: true do
    # ActionController::Base.allow_forgery_protection = true
    fill_and_submit_form
    click_button 'importButton'
    expect(find_field('Military Occupation Code').value).to have_content '111'
    expect(find_field('Branch of Service').value).to have_content 'string:army'
    fill_in 'Your full name', with: 'Suzy Veteran'
    fill_in 'Your email', with: 'suzy@veterans.org'
    click_button 'Preview Your Résumé Content'
    expect(page).to have_content '111'
    expect(page).to have_content 'Army'
    expect(page).to have_content 'Trainer'
    expect(page).to have_content 'Expert trainers do training'
  end

  scenario 'Skills are imported correctly into resume builder', js: true do
    fill_and_submit_form
    expect(page).to have_content 'Fake Skill 1'
    page.find('#skill_pill_1').click
    click_button 'importButton'
    expect(page).to have_content 'Fake Skill 1'
  end

  scenario 'Check-then-unchecked skills are not imported into resume builder', js: true do
    fill_and_submit_form
    expect(page).to have_content 'Fake Skill 1'
    page.find('#skill_pill_1').click
    page.find('#skill_pill_1').click
    click_button 'importButton'
    expect(page).to have_no_content 'Fake Skill 1'
  end

end

