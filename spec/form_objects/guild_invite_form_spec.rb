RSpec.describe GuildInviteForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { GuildInviteForm.new(guild: nil, character: nil) }

      it 'does not create new guild invite' do
        expect { service.persist? }.to_not change(GuildInvite, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:guild) { create :guild }
      let!(:character) { create :character }

      context 'for existed guild invite' do
        let!(:guild_invite) { create :guild_invite, guild: guild, character: character }
        let(:service) { GuildInviteForm.new(guild: guild, character: character) }

        it 'does not create new guild invite' do
          expect { service.persist? }.to_not change(GuildInvite, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for character in the guild' do
        let!(:other_character) { create :character, guild: guild }
        let(:service) { GuildInviteForm.new(guild: guild, character: other_character) }

        it 'does not create new guild invite' do
          expect { service.persist? }.to_not change(GuildInvite, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted guild invite' do
        let(:service) { GuildInviteForm.new(guild: guild, character: character) }

        it 'creates new guild invite' do
          expect { service.persist? }.to change { GuildInvite.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:character1) { create :character }
      let!(:character2) { create :character, world: character1.world, race: character1.race }
      let!(:guild) { create :guild, world: character1.world, fraction: character1.race.fraction }
      let!(:guild_invite1) { create :guild_invite, guild: guild, character: character1, from_guild: true }
      let!(:guild_invite2) { create :guild_invite, guild: guild, character: character2, from_guild: true }

      context 'for unexisted guild invite' do
        let(:service) { GuildInviteForm.new(id: 999, status: 1) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed guild invite' do
        context 'for invalid data' do
          let(:service) { GuildInviteForm.new(guild_invite1.attributes.merge(guild: guild_invite1.guild, character: guild_invite1.character, status: -1)) }

          it 'does not update guild invite' do
            service.persist?
            guild_invite1.reload

            expect(guild_invite1.status_send?).to eq true
          end
        end

        context 'for existed data' do
          let(:service) { GuildInviteForm.new(guild_invite1.attributes.merge(guild: guild_invite2.guild, character: guild_invite2.character, status: 1)) }

          it 'does not update guild invite' do
            service.persist?
            guild_invite1.reload

            expect(guild_invite1.status_send?).to eq true
          end
        end

        context 'for invalid status' do
          let(:service) { GuildInviteForm.new(guild_invite1.attributes.merge(guild: guild_invite1.guild, character: guild_invite1.character, status: 0)) }

          it 'does not update guild invite' do
            service.persist?
            guild_invite1.reload

            expect(guild_invite1.status_send?).to eq true
          end
        end

        context 'for valid data' do
          let(:service) { GuildInviteForm.new(guild_invite1.attributes.merge(guild: guild_invite1.guild, character: guild_invite1.character, status: 1)) }

          it 'updates guild invite' do
            service.persist?
            guild_invite1.reload

            expect(guild_invite1.status_declined?).to eq true
          end
        end
      end
    end
  end
end
