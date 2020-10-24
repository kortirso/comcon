# frozen_string_literal: true

describe BankRequestPolicy do
  let!(:user) { create :user }
  let!(:character1) { create :character, user: user }
  let!(:bank_request1) { create :bank_request, character: character1 }
  let!(:character2) { create :character, :orc, world: character1.world }
  let!(:bank_request2) { create :bank_request, character: character2 }

  describe '#destroy?' do
    context 'for not user character' do
      let(:policy) { described_class.new(bank_request2, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for user character' do
      let(:policy) { described_class.new(bank_request1, user: user) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.destroy?
    end
  end
end
