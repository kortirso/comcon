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
  end
end
