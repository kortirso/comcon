describe RebuildGuildRoles do
  let!(:guild) { create :guild }
  let!(:character1) { create :character, guild: guild }
  let!(:character2) { create :character, guild: guild }
  let!(:character3) { create :character, guild: guild }
  let!(:character4) { create :character, guild: guild }
  let!(:guild_role1) { create :guild_role, guild: guild, character: character1, name: 'gm' }
  let!(:guild_role2) { create :guild_role, guild: guild, character: character2, name: 'rl' }
  let!(:guild_role3) { create :guild_role, guild: guild, character: character3, name: 'cl' }

  describe '.call' do
    context 'for existed gm' do
      let(:interactor) { RebuildGuildRoles.call(guild: guild) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end
    end

    context 'for unexisted gm' do
      let(:interactor) { RebuildGuildRoles.call(guild: guild) }
      before { character1.destroy }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates rl to gm' do
        interactor
        guild_role2.reload

        expect(guild_role2.name).to eq 'gm'
      end
    end

    context 'for unexisted gm/rl' do
      let(:interactor) { RebuildGuildRoles.call(guild: guild) }
      before do
        character1.destroy
        character2.destroy
      end

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates cl to gm' do
        interactor
        guild_role3.reload

        expect(guild_role3.name).to eq 'gm'
      end
    end

    context 'for unexisted gm/rl/cl' do
      let(:interactor) { RebuildGuildRoles.call(guild: guild) }
      before do
        character1.destroy
        character2.destroy
        character3.destroy
      end

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates new role for character' do
        expect { interactor }.to change { guild.guild_roles.count }.by(1)
      end
    end

    context 'for empty characters' do
      let(:interactor) { RebuildGuildRoles.call(guild: guild) }
      before { guild.characters.destroy_all }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and deletes guild' do
        expect { interactor }.to change { Guild.count }.by(-1)
      end
    end
  end
end
