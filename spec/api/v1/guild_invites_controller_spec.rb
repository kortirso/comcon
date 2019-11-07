RSpec.describe 'GuildInvites API' do
  describe 'POST#create' do
    let!(:race) { create :race, :human }
    let!(:guild) { create :guild, fraction: race.fraction }
    let!(:character) { create :character, guild_id: nil, race: race }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let!(:user_character) { create :character, guild: guild, race: race, user: user }
      let!(:guild_role) { create :guild_role, guild: guild, character: user_character, name: 'gm' }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let(:request) { post '/api/v1/guild_invites.json', params: { access_token: access_token, guild_invite: { guild_id: guild.id, character_id: user_character.id, from_guild: 'true' } } }

        it 'does not create new guild invite' do
          expect { request }.to_not change(GuildInvite, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 409' do
            expect(response.status).to eq 409
          end

          it 'and returns errors' do
            expect(JSON.parse(response.body)['errors']).to_not eq nil
          end
        end
      end

      context 'for valid params' do
        let(:request) { post '/api/v1/guild_invites.json', params: { access_token: access_token, guild_invite: { guild_id: guild.id, character_id: character.id, from_guild: 'true' } } }

        it 'calls CreateGuildInvite' do
          expect(CreateGuildInvite).to receive(:call).and_call_original

          request
        end

        it 'and creates new guild invite' do
          expect { request }.to change { GuildInvite.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id guild_id character_id from_guild].each do |attr|
            it "and contains guild_role #{attr}" do
              expect(response.body).to have_json_path("guild_invite/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/guild_invites.json', params: { guild_invite: { guild_id: guild.id, character_id: character.id, from_guild: 'true' } }, headers: headers
    end
  end
end
