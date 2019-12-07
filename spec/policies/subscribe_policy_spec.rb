describe SubscribePolicy do
  let!(:user) { create :user }
  let!(:user_character) { create :character, user: user }
  let!(:owner) { create :user }
  let!(:owner_character) { create :character, user: owner }
  let!(:event) { create :event, owner: owner_character }
  let!(:closed_event) { create :event, owner: owner_character, start_time: DateTime.now + 1.hour, hours_before_close: 24 }
  let!(:guild) { create :guild }
  let!(:guild_character1) { create :character, user: user, guild: guild }
  let!(:guild_character2) { create :character, user: owner, guild: guild }
  let!(:character_class) { create :character_class, :warrior }
  let!(:guild_character3) { create :character, user: owner, guild: guild, character_class: character_class }
  let!(:guild_event) { create :event, eventable: guild }

  describe '#create?' do
    context 'for event' do
      context 'for invalid status' do
        let(:policy) { described_class.new(event, user: user, status: 'approved') }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end

      context 'for valid status' do
        context 'for open event' do
          let(:policy) { described_class.new(event, user: user, status: 'signed') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end

        context 'for closed event' do
          let(:policy) { described_class.new(closed_event, user: user, status: 'signed') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end
      end
    end

    context 'for static' do
      let!(:static) { create :static, staticable: owner_character }

      context 'for user without rights in static' do
        let(:policy) { described_class.new(static, user: user, status: 'approved') }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end

      context 'for user with rights in static' do
        let(:policy) { described_class.new(static, user: owner, status: 'approved') }

        it 'returns true' do
          expect(policy_access).to eq true
        end
      end
    end

    def policy_access
      policy.create?
    end
  end

  describe '#update?' do
    context 'for simple user' do
      context 'for not user subscribe' do
        context 'world event' do
          let!(:subscribe) { create :subscribe, character: owner_character, status: 'signed', subscribeable: event }
          let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end

        context 'guild event, without guild role, permitted status' do
          let!(:subscribe) { create :subscribe, character: owner_character, status: 'signed', subscribeable: guild_event }
          let(:policy) { described_class.new(subscribe, user: user, status: 'unknown') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end

        context 'guild event, without guild role, valid status' do
          let!(:subscribe) { create :subscribe, character: owner_character, status: 'signed', subscribeable: guild_event }
          let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end

        context 'guild event, with rl guild role, valid status' do
          let!(:subscribe) { create :subscribe, character: guild_character2, status: 'signed', subscribeable: guild_event }
          let!(:guild_role) { create :guild_role, guild: guild, character: guild_character1, name: 'rl' }
          let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end

        context 'guild event, with cl guild role, same classes, valid status' do
          let!(:subscribe) { create :subscribe, character: guild_character2, status: 'signed', subscribeable: guild_event }
          let!(:guild_role) { create :guild_role, guild: guild, character: guild_character1, name: 'cl' }
          let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end

        context 'guild event, with cl guild role, different classes, valid status' do
          let!(:subscribe) { create :subscribe, character: guild_character3, status: 'signed', subscribeable: guild_event }
          let!(:guild_role) { create :guild_role, guild: guild, character: guild_character1, name: 'cl' }
          let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end
      end

      context 'for user subscribe' do
        let!(:subscribe) { create :subscribe, character: user_character, status: 'signed', subscribeable: event }

        context 'to approved' do
          let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end

        context 'to rejected, for closed event' do
          let!(:closed_subscribe) { create :subscribe, character: user_character, status: 'signed', subscribeable: closed_event }
          let(:policy) { described_class.new(closed_subscribe, user: user, status: 'rejected') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end

        context 'to rejected' do
          let(:policy) { described_class.new(subscribe, user: user, status: 'rejected') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end
      end
    end

    context 'for owner' do
      context 'for not owner subscribe' do
        let!(:subscribe) { create :subscribe, character: user_character, status: 'signed', subscribeable: event }

        context 'to approved' do
          let(:policy) { described_class.new(subscribe, user: owner, status: 'approved') }

          it 'returns true' do
            expect(policy_access).to eq true
          end
        end

        context 'to unknown' do
          let(:policy) { described_class.new(subscribe, user: owner, status: 'unknown') }

          it 'returns false' do
            expect(policy_access).to eq false
          end
        end
      end

      context 'for owner subscribe' do
        let!(:subscribe) { create :subscribe, character: owner_character, status: 'signed', subscribeable: event }

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

    context 'for static' do
      let!(:static) { create :static, staticable: owner_character }
      let!(:subscribe) { create :subscribe, character: user_character, status: 'reserve', subscribeable: static }

      context 'for user without rights in static' do
        let(:policy) { described_class.new(subscribe, user: user, status: 'approved') }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end

      context 'for user with rights in static' do
        let(:policy) { described_class.new(subscribe, user: owner, status: 'approved') }

        it 'returns true' do
          expect(policy_access).to eq true
        end
      end
    end

    def policy_access
      policy.update?
    end
  end
end
