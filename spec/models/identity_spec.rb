# frozen_string_literal: true

RSpec.describe Identity, type: :model do
  it { is_expected.to belong_to :user }

  it 'factory is_expected.to be valid' do
    identity = build :identity

    expect(identity).to be_valid
  end

  describe 'class methods' do
    describe '.find_for_oauth' do
      let(:oauth) { create :oauth }

      context 'for unexisted identity' do
        it 'returns nil' do
          expect(described_class.find_for_oauth(oauth)).to eq nil
        end
      end

      context 'for existed identity' do
        let!(:identity) { create :identity, uid: oauth.uid }

        it 'returns identity object' do
          expect(described_class.find_for_oauth(oauth)).to eq identity
        end
      end
    end
  end
end
