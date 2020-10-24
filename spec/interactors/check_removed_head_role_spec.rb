# frozen_string_literal: true

describe CheckRemovedHeadRole do
  let!(:user) { create :user }
  let!(:character) { create :character, user: user }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction }
  let!(:gm1) { create :character, user: user, guild: guild }
  let!(:guild_role1) { create :guild_role, character: gm1, guild: guild, name: 'gm' }
  let!(:gm2) { create :character, user: user, guild: guild }
  let!(:guild_role2) { create :guild_role, character: gm2, guild: guild, name: 'gm' }
  let!(:gm3) { create :character, guild: guild }
  let!(:guild_role3) { create :guild_role, character: gm3, guild: guild, name: 'gm' }
  let!(:rl) { create :character, guild: guild }
  let!(:guild_role4) { create :guild_role, character: rl, guild: guild, name: 'rl' }
  let!(:notification) { create :notification, event: 'guild_request_creation', status: 1 }
  let!(:delivery1) { create :delivery, deliveriable: user, notification: notification }
  let!(:delivery2) { create :delivery, deliveriable: gm3.user, notification: notification }

  describe '.call' do
    context 'for not gm role' do
      let(:interactor) { described_class.call(guild_role: guild_role4) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not delete delivery' do
        expect { interactor }.not_to change(Delivery, :count)
      end
    end

    context 'for user with many gm characters' do
      let(:interactor) { described_class.call(guild_role: guild_role1) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not delete delivery' do
        expect { interactor }.not_to change(Delivery, :count)
      end
    end

    context 'for user with one gm character' do
      let(:interactor) { described_class.call(guild_role: guild_role3) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and deletes delivery' do
        expect { interactor }.to change(Delivery, :count).by(-1)
      end

      it 'and this is user deliveries' do
        interactor

        expect(gm3.user.deliveries.count).to eq 0
      end
    end
  end
end
