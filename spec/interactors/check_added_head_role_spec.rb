# frozen_string_literal: true

describe CheckAddedHeadRole do
  let!(:user) { create :user }
  let!(:character) { create :character, user: user }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction }
  let!(:gm1) { create :character, user: user, guild: guild }
  let!(:guild_role1) { create :guild_role, character: gm1, guild: guild, name: 'gm' }
  let!(:rl) { create :character, guild: guild }
  let!(:guild_role2) { create :guild_role, character: rl, guild: guild, name: 'rl' }

  describe '.call' do
    context 'for not gm role' do
      let(:interactor) { described_class.call(guild_role: guild_role2) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not delete delivery' do
        expect { interactor }.not_to change(Delivery, :count)
      end
    end

    context 'for not existed guild notification' do
      let(:interactor) { described_class.call(guild_role: guild_role1) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not create delivery' do
        expect { interactor }.not_to change(Delivery, :count)
      end

      context 'for existed guild notification' do
        let!(:guild_notification) { create :notification, event: 'guild_request_creation', status: 0 }

        context 'for not existed guild delivery' do
          it 'succeeds' do
            expect(interactor).to be_a_success
          end

          it 'and does not create delivery' do
            expect { interactor }.not_to change(Delivery, :count)
          end
        end

        context 'for existed guild delivery' do
          let!(:delivery1) { create :delivery, deliveriable: guild, notification: guild_notification }

          context 'for not existed user notification' do
            it 'succeeds' do
              expect(interactor).to be_a_success
            end

            it 'and does not create delivery' do
              expect { interactor }.not_to change(Delivery, :count)
            end
          end

          context 'for existed user notification' do
            let!(:user_notification) { create :notification, event: 'guild_request_creation', status: 1 }

            context 'for existed user delivery' do
              let!(:delivery2) { create :delivery, deliveriable: user, notification: user_notification }

              it 'succeeds' do
                expect(interactor).to be_a_success
              end

              it 'and does not create delivery' do
                expect { interactor }.not_to change(Delivery, :count)
              end
            end

            context 'for not existed user delivery' do
              it 'succeeds' do
                expect(interactor).to be_a_success
              end

              it 'and creates new delivery' do
                expect { interactor }.to change(Delivery, :count).by(1)
              end
            end
          end
        end
      end
    end
  end
end
