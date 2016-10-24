require 'rails_helper'

describe RetriableSearchRequest do
  describe '#search' do
    subject(:search) {
      described_class.new.search({}) do
        described_class.get('http://example.com')
      end
    }

    context 'when a request succeeds' do
      before do
        expect(described_class).to receive(:get).and_return(:ok)
      end

      it { is_expected.to be(:ok) }
    end

    context 'when a request times out before MAX_ATTEMPTS reached' do
      before do
        expect(described_class).to receive(:get).and_raise(Timeout::Error)
        expect(described_class).to receive(:get).and_return(:ok)
      end

      it { is_expected.to be(:ok) }
    end

    context 'when a request times out after MAX_ATTEMPTS reached' do
      before do
        expect(described_class).to receive(:get).twice.and_raise(Timeout::Error)
      end

      # ;( https://github.com/rspec/rspec-expectations/issues/805
      it 'should raise Timeout::Error' do
        expect{subject}.to raise_error(Timeout::Error)
      end
    end
  end
end
