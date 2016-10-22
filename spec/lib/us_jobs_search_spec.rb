require 'rails_helper'

describe UsJobsSearch do
  describe '#search' do
    subject(:search) { described_class.new.search({}) }

    context 'when a request succeeds' do
      before do
        expect(described_class).to receive(:get).and_return(:ok)
      end

      it { is_expected.to be(:ok) }
    end
  end
end
