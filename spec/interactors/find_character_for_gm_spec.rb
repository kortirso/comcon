# frozen_string_literal: true

describe FindCharacterForGm do
  let!(:user) { create :user }
  let!(:character) { create :character, user: user }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction }

  describe '.call' do
    let(:interactor) { described_class.call(user: user, owner_id: character.id) }

    context 'for character with guild' do
      before { character.update(guild_id: guild.id) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end
    end

    context 'for character without guild' do
      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and provides character' do
        expect(interactor.character).to eq character
      end
    end
  end
end
