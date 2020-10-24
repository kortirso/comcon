# frozen_string_literal: true

describe CreateGuildRole do
  let!(:guild) { create :guild }
  let!(:character) { create :character, guild: guild }
  let!(:other_character) { create :character }

  describe '.call' do
    context 'for existed guild role' do
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let(:interactor) { described_class.call(guild: guild, character: character, name: 'gm') }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create guild role' do
        expect { interactor }.not_to change(guild.guild_roles, :count)
      end
    end

    context 'for other character' do
      let(:interactor) { described_class.call(guild: guild, character: other_character, name: 'gm') }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create guild role' do
        expect { interactor }.not_to change(guild.guild_roles, :count)
      end
    end

    context 'for unexisted guild role' do
      let(:interactor) { described_class.call(guild: guild, character: character, name: 'gm') }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates guild role' do
        expect { interactor }.to change { guild.guild_roles.count }.by(1)
      end
    end
  end
end
