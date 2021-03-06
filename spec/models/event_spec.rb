# frozen_string_literal: true

RSpec.describe Event, type: :model do
  it { is_expected.to belong_to(:owner).class_name('Character') }
  it { is_expected.to belong_to(:dungeon).optional }
  it { is_expected.to belong_to :eventable }
  it { is_expected.to belong_to :fraction }
  it { is_expected.to belong_to :world_fraction }
  it { is_expected.to have_many(:subscribes).dependent(:destroy) }
  it { is_expected.to have_many(:characters).through(:subscribes) }
  it { is_expected.to have_many(:signed_subscribes).class_name('Subscribe') }
  it { is_expected.to have_many(:signed_characters).through(:signed_subscribes).source(:character) }
  it { is_expected.to have_many(:signed_users).through(:signed_characters).source(:user) }
  it { is_expected.to have_one(:group_role).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    event = create :event

    expect(event).to be_valid
  end

  describe 'class methods' do
    context 'availability' do
      let!(:user) { create :user }
      let!(:character1) { create :character, user: user }
      let!(:guild) { create :guild, world: character1.world, fraction: character1.race.fraction }
      let!(:character2) { create :character, :orc, world: character1.world }
      let!(:character3) { create :character, world: character1.world, race: character1.race, user: user, guild: guild }
      let!(:world_event1) { create :event, eventable: character1.world, fraction: character1.race.fraction }
      let!(:world_event2) { create :event, eventable: character1.world, fraction: character2.race.fraction }
      let!(:guild_event) { create :event, eventable: guild, fraction: character1.race.fraction }
      let!(:static) { create :static, staticable: guild }
      let!(:static_member) { create :static_member, static: static, character: character1 }
      let!(:static_event) { create :event, eventable: static, fraction: character3.race.fraction }
      let!(:guild_role) { create :guild_role, guild: guild, character: character3, name: 'rl' }

      describe '.available_for_user' do
        context 'if no subscribes' do
          context 'when user is not in guild' do
            before { character3.update(guild: nil) }

            it 'returns no events' do
              result = described_class.available_for_user(user)

              expect(result.size.zero?).to eq true
            end
          end

          context 'when user in guild' do
            it 'returns guild static events' do
              result = described_class.available_for_user(user)

              expect(result.size).to eq 1
              expect(result.include?(static_event)).to eq true
            end
          end
        end

        context 'if subscribed' do
          let!(:subscribe) { create :subscribe, character: character1, subscribeable: guild_event }

          it 'returns events where user is subscribed + guild static events' do
            result = described_class.available_for_user(user)

            expect(result.size).to eq 2
            expect(result.include?(guild_event)).to eq true
            expect(result.include?(static_event)).to eq true
          end
        end
      end

      describe '.available_for_character' do
        context 'if no subscribes' do
          it 'returns no events' do
            result = described_class.available_for_character(character1.id)

            expect(result.size.zero?).to eq true
          end
        end

        context 'if subscribed' do
          let!(:subscribe) { create :subscribe, character: character1, subscribeable: guild_event }

          it 'returns events where user is subscribed' do
            result = described_class.available_for_character(character1.id)

            expect(result.size).to eq 1
            expect(result.include?(guild_event)).to eq true
          end
        end
      end
    end
  end

  describe 'methods' do
    describe '.is_open?' do
      context 'for open event' do
        let!(:event) { create :event }

        it 'returns true' do
          expect(event.is_open?).to eq true
        end
      end

      context 'for open event' do
        let!(:event) { create :event, hours_before_close: 24 }

        it 'returns false' do
          expect(event.is_open?).to eq false
        end
      end
    end

    describe '.guild_role_of_user' do
      let!(:user) { create :user }

      context 'for world event' do
        let!(:event) { create :event }

        it 'returns nil' do
          result = event.guild_role_of_user(user.id)

          expect(result).to eq nil
        end
      end

      context 'for guild event' do
        let!(:guild) { create :guild }
        let!(:event) { create :event, eventable: guild }

        context 'without characters' do
          it 'returns nil' do
            result = event.guild_role_of_user(user.id)

            expect(result).to eq nil
          end
        end

        context 'without leaders characters of user' do
          let!(:character) { create :character, guild: guild }
          let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'rl' }

          it 'returns nil' do
            result = event.guild_role_of_user(user.id)

            expect(result).to eq nil
          end
        end

        context 'with leaders characters of user' do
          let!(:character) { create :character, guild: guild, user: user }

          context 'with rl' do
            let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'rl' }

            it 'returns result' do
              result = event.guild_role_of_user(user.id)

              expect(result).to eq ['rl', nil]
            end
          end

          context 'with cl' do
            let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'cl' }

            it 'returns result' do
              result = event.guild_role_of_user(user.id)

              expect(result).to eq ['cl', [character.character_class.name['en']]]
            end
          end
        end
      end

      context 'for static event' do
        context 'if owner is character' do
          let!(:static) { create :static, :character }
          let!(:event) { create :event, eventable: static }

          it 'returns nil' do
            result = event.guild_role_of_user(user.id)

            expect(result).to eq nil
          end
        end

        context 'if owner is guild' do
          let!(:guild) { create :guild }
          let!(:static) { create :static, staticable: guild }
          let!(:event) { create :event, eventable: static }

          context 'without characters' do
            it 'returns nil' do
              result = event.guild_role_of_user(user.id)

              expect(result).to eq nil
            end
          end

          context 'without leaders characters of user' do
            let!(:character) { create :character, guild: guild, world: guild.world }
            let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'rl' }

            it 'returns nil' do
              result = event.guild_role_of_user(user.id)

              expect(result).to eq nil
            end
          end

          context 'with leaders characters of user' do
            let!(:character) { create :character, guild: guild, user: user }

            context 'with rl' do
              let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'rl' }

              it 'returns result' do
                result = event.guild_role_of_user(user.id)

                expect(result).to eq ['rl', nil]
              end
            end

            context 'with cl' do
              let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'cl' }

              it 'returns result' do
                result = event.guild_role_of_user(user.id)

                expect(result).to eq ['cl', [character.character_class.name['en']]]
              end
            end
          end
        end
      end
    end
  end
end
