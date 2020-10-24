# frozen_string_literal: true

describe DeleteStaticInvite do
  let!(:guild) { create :guild }
  let!(:character) { create :character, guild: guild }
  let!(:static) { create :static, staticable: guild, world: character.world, fraction: character.race.fraction }
  let!(:static_invite1) { create :static_invite, static: static, character: character, from_static: true }
  let!(:static_invite2) { create :static_invite, static: static, character: character, from_static: false }

  describe '.call' do
    let(:interactor) { described_class.call(static: static, character: character) }

    it 'succeeds' do
      expect(interactor).to be_a_success
    end

    it 'and deletes static invite' do
      expect { interactor }.to change(StaticInvite, :count).by(-2)
    end
  end
end
