RSpec.describe GuildRoleForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { GuildRoleForm.new(name: '') }

      it 'does not create new guild role' do
        expect { service.persist? }.to_not change(GuildRole, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild }

      context 'for existed guild role' do
        let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
        let(:service) { GuildRoleForm.new(guild: guild, character: character, name: 'rl') }

        it 'does not create new guild role' do
          expect { service.persist? }.to_not change(GuildRole, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for character not in the guild' do
        let!(:other_character) { create :character }
        let(:service) { GuildRoleForm.new(guild: guild, character: other_character, name: 'rl') }

        it 'does not create new guild role' do
          expect { service.persist? }.to_not change(GuildRole, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted guild role' do
        let(:service) { GuildRoleForm.new(guild: guild, character: character, name: 'rl') }

        it 'creates new guild role' do
          expect { service.persist? }.to change { GuildRole.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      context 'for unexisted guild role' do
        let(:service) { GuildRoleForm.new(id: 999, name: '1') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed guild role' do
        let!(:guild1) { create :guild }
        let!(:character1) { create :character, guild: guild1 }
        let!(:guild_role1) { create :guild_role, name: 'rl', guild: guild1, character: character1 }
        let!(:guild2) { create :guild }
        let!(:character2) { create :character, guild: guild2 }
        let!(:guild_role2) { create :guild_role, name: 'rl', guild: guild2, character: character2 }

        context 'for invalid data' do
          let(:service) { GuildRoleForm.new(id: guild_role1.id, name: '', guild: guild_role1.guild, character: guild_role1.character) }

          it 'does not update guild' do
            service.persist?
            guild_role1.reload

            expect(guild_role1.name).to_not eq ''
          end
        end

        context 'for existed data' do
          let(:service) { GuildRoleForm.new(id: guild_role1.id, name: 'gm', guild: guild_role2.guild, character: guild_role2.character) }

          it 'does not update guild' do
            service.persist?
            guild_role1.reload

            expect(guild_role1.name).to_not eq 'gm'
          end
        end

        context 'for valid data' do
          let(:service) { GuildRoleForm.new(id: guild_role1.id, name: 'gm', guild: guild_role1.guild, character: guild_role1.character) }

          it 'does not update guild' do
            service.persist?
            guild_role1.reload

            expect(guild_role1.name).to eq 'gm'
          end
        end
      end
    end
  end
end
