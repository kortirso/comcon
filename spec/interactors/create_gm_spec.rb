# frozen_string_literal: true

describe CreateGm do
  let!(:user) { create :user }
  let!(:character) { create :character, user: user }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction }

  describe '.call' do
    context 'for valid params' do
      let(:interactor) { described_class.call(guild: guild, character: character) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates character' do
        interactor
        character.reload

        expect(character.guild_id).not_to eq nil
      end
    end
  end

  describe '.rollback' do
    subject(:interactor) { described_class.new(guild: guild, character: character) }

    it 'updates character back' do
      interactor.call
      interactor.rollback
      character.reload

      expect(character.guild_id).to eq nil
    end
  end
end
