RSpec.describe Identity, type: :model do
  it { should belong_to :user }

  it 'factory should be valid' do
    identity = build :identity

    expect(identity).to be_valid
  end

  describe 'class methods' do
    context '.find_for_oauth' do
      let(:oauth) { create :oauth }

      context 'for unexisted identity' do
        it 'returns nil' do
          expect(Identity.find_for_oauth(oauth)).to eq nil
        end
      end

      context 'for existed identity' do
        let!(:identity) { create :identity, uid: oauth.uid }

        it 'returns identity object' do
          expect(Identity.find_for_oauth(oauth)).to eq identity
        end
      end
    end
  end
end
