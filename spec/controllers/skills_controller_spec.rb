require 'rails_helper'

describe SkillsController do
  describe '#get_skills' do
    context 'when provided a matching prefix' do
      let(:skill) { create(:skill, source: 'linkedin') }

      before do
        get :get_skills, prefix: skill.name[0..2]
      end

      it 'finds the skill' do
        expect(assigns[:skills]).to include(skill)
      end

      it 'responds successfully' do
        expect(response.code).to eq('200')
      end
    end

    context 'when provided a quoted prefix' do
      before do
        get :get_skills, prefix: "master's"
      end

      it 'responds successfully' do
        expect(response.code).to eq('200')
      end
    end
  end
end
