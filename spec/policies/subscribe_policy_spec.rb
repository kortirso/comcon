describe SubscribePolicy do
  let!(:user) { create :user }
  let!(:user_character) { create :character, user: user }
  let!(:owner) { create :user }
  let!(:owner_character) { create :character, user: owner }
  let!(:event) { create :event, owner: owner_character }

  describe '#update?' do
    context 'for simple user' do
      context 'for not user subscribe' do
        let!(:subscribe) { create :subscribe, character: owner_character, status: 'signed', event: event }
        let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end

      context 'for user subscribe' do
        let!(:subscribe) { create :subscribe, character: user_character, status: 'signed', event: event }

        context 'for user subscribe, to approved' do
          let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end

        context 'for user subscribe, to rejected' do
          let(:policy) { described_class.new(subscribe, user: user, status: 'rejected') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end
      end
    end

    context 'for owner' do
      context 'for not owner subscribe' do
        let!(:subscribe) { create :subscribe, character: user_character, status: 'signed', event: event }

        context 'to approved' do
          let(:policy) { described_class.new(subscribe, user: owner, status: 'approved') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end

        context 'to unknown' do
          let(:policy) { described_class.new(subscribe, user: owner, status: 'unknown') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end
      end

      context 'for owner subscribe' do
        let!(:subscribe) { create :subscribe, character: owner_character, status: 'signed', event: event }

        context 'to approved' do
          let(:policy) { described_class.new(subscribe, user: owner, status: 'approved') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end

        context 'to rejected' do
          let(:policy) { described_class.new(subscribe, user: owner, status: 'rejected') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end
      end
    end

    def policy_access
      policy.update?
    end
  end
end
