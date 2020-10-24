# frozen_string_literal: true

describe CreateGuildInvite do
  let!(:user) { create :user }
  let!(:guild) { create :guild }
  let!(:character) { create :character, user: user }
  let!(:other_character) { create :character, guild: guild }

  describe '.call' do
    context 'for existed guild invite' do
      let!(:guild_invite) { create :guild_invite, guild: guild, character: character, from_guild: true }
      let(:interactor) { described_class.call(guild: guild, character: character, from_guild: true) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create guild invite' do
        expect { interactor }.not_to change(guild.guild_invites, :count)
      end
    end

    context 'for other character' do
      let(:interactor) { described_class.call(guild: guild, character: other_character, from_guild: true) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create guild invite' do
        expect { interactor }.not_to change(guild.guild_invites, :count)
      end
    end

    context 'for unexisted guild invite' do
      let(:interactor) { described_class.call(guild: guild, character: character, from_guild: true) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and calls CreateGuildRequestJob' do
        expect(CreateGuildRequestJob).to receive(:perform_later).and_call_original

        interactor
      end

      it 'and creates guild invite' do
        expect { interactor }.to change { guild.guild_invites.count }.by(1)
      end
    end

    context 'if user has characters in guild' do
      let!(:guild_character) { create :character, user: user, guild: guild }
      let!(:guild_invite) { create :guild_invite, character: character }
      let(:interactor) { described_class.call(guild: guild, character: character, from_guild: false) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not create guild invite' do
        expect { interactor }.not_to change(guild.guild_invites, :count)
      end

      it 'and updates character' do
        interactor
        character.reload

        expect(character.guild_id).to eq guild.id
      end

      it 'and provides result' do
        expect(interactor.guild_invite).to eq(result: 'Approved')
      end

      it 'and character does not have more guild invites' do
        interactor
        character.reload

        expect(character.guild_invites.size).to eq 0
      end
    end
  end
end
