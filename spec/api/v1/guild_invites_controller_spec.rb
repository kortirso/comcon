RSpec.describe 'GuildInvites API' do
  describe 'GET#index' do
    let!(:guild) { create :guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'without guild or character param' do
        before { get '/api/v1/guild_invites.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Guild ID or Character ID must be presented')
        end
      end

      context 'with guild param' do
        context 'for unexisted guild' do
          before { get '/api/v1/guild_invites.json', params: { access_token: access_token, guild_id: 'unexisted' } }

          it 'returns status 400' do
            expect(response.status).to eq 400
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed guild' do
          let!(:character) { create :character, guild: guild, user: user }
          let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }
          let!(:guild_invite) { create :guild_invite, guild: guild }
          before { get '/api/v1/guild_invites.json', params: { access_token: access_token, guild_id: guild.id } }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          %w[id guild character from_guild status].each do |attr|
            it "and contains guild_invite #{attr}" do
              expect(response.body).to have_json_path("guild_invites/0/#{attr}")
            end
          end
        end
      end

      context 'with character param' do
        context 'for unexisted character' do
          before { get '/api/v1/guild_invites.json', params: { access_token: access_token, character_id: 'unexisted' } }

          it 'returns status 400' do
            expect(response.status).to eq 400
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed character' do
          context 'for not user character' do
            let!(:character) { create :character }
            before { get '/api/v1/guild_invites.json', params: { access_token: access_token, character_id: character.id } }

            it 'returns status 400' do
              expect(response.status).to eq 400
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
            end
          end

          context 'for character with guild' do
            let!(:character) { create :character, guild: guild, user: user }
            before { get '/api/v1/guild_invites.json', params: { access_token: access_token, character_id: character.id } }

            it 'returns status 400' do
              expect(response.status).to eq 400
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
            end
          end

          context 'for valid character' do
            let!(:character) { create :character, user: user, guild_id: nil }
            let!(:guild_invite) { create :guild_invite, guild: guild, character: character, from_guild: true }
            before { get '/api/v1/guild_invites.json', params: { access_token: access_token, character_id: character.id } }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id guild character from_guild status].each do |attr|
              it "and contains guild_invite #{attr}" do
                expect(response.body).to have_json_path("guild_invites/0/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guild_invites.json', params: { guild_id: guild.id }, headers: headers
    end
  end

  describe 'POST#create' do
    let!(:race) { create :race, :human }
    let!(:guild) { create :guild, fraction: race.fraction }
    let!(:character) { create :character, guild_id: nil, race: race }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

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

          %w[id guild character from_guild status].each do |attr|
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

  describe 'DELETE#destroy' do
    let(:other_guild_invite) { create :guild_invite }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:user_character) { create :character, guild: guild, user: user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild invite' do
        before { delete '/api/v1/guild_invites/unexisted.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild invite' do
        let!(:guild_invite) { create :guild_invite, guild: guild, from_guild: true }

        context 'for unavailable guild invite' do
          before { delete "/api/v1/guild_invites/#{guild_invite.id}.json", params: { access_token: access_token } }

          it 'does not delete guild invite' do
            expect { request }.to_not change(GuildInvite, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 400' do
              expect(response.status).to eq 400
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)).to eq('error' => 'Forbidden')
            end
          end
        end

        context 'for available guild invite' do
          let!(:guild_role) { create :guild_role, guild: guild, character: user_character, name: 'gm' }
          let(:request) { delete "/api/v1/guild_invites/#{guild_invite.id}.json", params: { access_token: access_token } }

          it 'deletes guild invite' do
            expect { request }.to change { GuildInvite.count }.by(-1)
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            it 'and returns result message' do
              expect(JSON.parse(response.body)).to eq('result' => 'Guild invite is deleted')
            end
          end
        end
      end
    end

    def do_request(headers = {})
      delete "/api/v1/guild_invites/#{other_guild_invite.id}.json", headers: headers
    end
  end

  describe 'POST#approve' do
    let(:other_guild_invite) { create :guild_invite }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:user_character) { create :character, guild: guild, user: user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild invite' do
        before { post '/api/v1/guild_invites/unexisted/approve.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild invite' do
        let!(:character) { create :character }
        let!(:guild_invite) { create :guild_invite, guild: guild, character: character, from_guild: false }
        let!(:guild_role) { create :guild_role, guild: guild, character: user_character, name: 'gm' }
        let(:request) { post "/api/v1/guild_invites/#{guild_invite.id}/approve.json", params: { access_token: access_token } }

        it 'updates character guild' do
          request
          character.reload

          expect(character.guild_id).to eq guild.id
        end

        it 'and deletes guild invite' do
          expect { request }.to change { GuildInvite.count }.by(-1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns result message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Character is added to the guild')
          end
        end
      end
    end

    def do_request(headers = {})
      post "/api/v1/guild_invites/#{other_guild_invite.id}/approve.json", headers: headers
    end
  end

  describe 'POST#decline' do
    let(:other_guild_invite) { create :guild_invite }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:user_character) { create :character, guild: guild, user: user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild invite' do
        before { post '/api/v1/guild_invites/unexisted/decline.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild invite' do
        let!(:character) { create :character }
        let!(:guild_invite) { create :guild_invite, guild: guild, character: character, from_guild: false }
        let!(:guild_role) { create :guild_role, guild: guild, character: user_character, name: 'gm' }
        let(:request) { post "/api/v1/guild_invites/#{guild_invite.id}/decline.json", params: { access_token: access_token } }

        it 'does not update character guild' do
          request
          character.reload

          expect(character.guild_id).to eq nil
        end

        it 'calls UpdateGuildInvite' do
          expect(UpdateGuildInvite).to receive(:call).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns result message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Guild invite is declined')
          end
        end
      end
    end

    def do_request(headers = {})
      post "/api/v1/guild_invites/#{other_guild_invite.id}/decline.json", headers: headers
    end
  end
end
