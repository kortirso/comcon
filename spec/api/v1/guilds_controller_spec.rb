RSpec.describe 'Guilds API' do
  describe 'GET#index' do
    let!(:guild) { create :guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'without additional params' do
        before { get '/api/v1/guilds.json', params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name description slug fraction_id fraction_name world_id world_name].each do |attr|
          it "and contains guild #{attr}" do
            expect(response.body).to have_json_path("guilds/0/#{attr}")
          end
        end
      end

      context 'with fraction param' do
        before { get '/api/v1/guilds.json', params: { access_token: access_token, fraction_id: guild.fraction_id } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end
      end

      context 'with world param' do
        before { get '/api/v1/guilds.json', params: { access_token: access_token, world_id: guild.world_id } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guilds.json', headers: headers
    end
  end

  describe 'GET#show' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { get '/api/v1/guilds/unexisted.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        let!(:guild) { create :guild }
        before { get "/api/v1/guilds/#{guild.id}.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name description slug].each do |attr|
          it "and contains guild #{attr}" do
            expect(response.body).to have_json_path("guild/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guilds/unexisted.json', headers: headers
    end
  end

  describe 'POST#create' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:character) { create :character, user: user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let(:request) { post '/api/v1/guilds.json', params: { access_token: access_token, guild: { name: '', description: '123', owner_id: 0 } } }

        it 'calls CreateNewGuild' do
          expect(CreateNewGuild).to receive(:call).and_call_original

          request
        end

        it 'and does not create new guild' do
          expect { request }.to_not change(Guild, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 409' do
            expect(response.status).to eq 409
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)['errors']).to_not eq nil
          end
        end
      end

      context 'for valid params' do
        let(:request) { post '/api/v1/guilds.json', params: { access_token: access_token, guild: { name: '123', description: '123', owner_id: character.id } } }

        it 'calls CreateNewGuild' do
          expect(CreateNewGuild).to receive(:call).and_call_original

          request
        end

        it 'and creates new guild' do
          expect { request }.to change { Guild.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id name description slug].each do |attr|
            it "and contains guild #{attr}" do
              expect(response.body).to have_json_path("guild/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/guilds.json', params: { guild: { name: '1', description: '2' } }, headers: headers
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { patch '/api/v1/guilds/unexisted.json', params: { access_token: access_token, guild: { name: '123', description: '123' } } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed static' do
        context 'for invalid params' do
          let(:request) { patch "/api/v1/guilds/#{guild.id}.json", params: { access_token: access_token, guild: { name: '', description: '123' } } }

          it 'does not update guild' do
            request
            guild.reload

            expect(guild.name).to_not eq ''
          end

          context 'in answer' do
            before { request }

            it 'returns status 409' do
              expect(response.status).to eq 409
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)['errors']).to_not eq nil
            end
          end
        end

        context 'for valid params' do
          let(:request) { patch "/api/v1/guilds/#{guild.id}.json", params: { access_token: access_token, guild: { name: '321', description: '123' } } }

          it 'updates guild' do
            request
            guild.reload

            expect(guild.name).to eq '321'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id name description slug].each do |attr|
              it "and contains guild #{attr}" do
                expect(response.body).to have_json_path("guild/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      patch '/api/v1/guilds/unexisted.json', params: { guild: { name: '1' } }, headers: headers
    end
  end

  describe 'GET#form_values' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/guilds/form_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[characters].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guilds/form_values.json', headers: headers
    end
  end

  describe 'GET#characters' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { get '/api/v1/guilds/999/characters.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        let!(:guild) { create :guild }
        let!(:character) { create :character, guild: guild }
        let!(:character_role) { create :character_role, character: character, main: true }
        before { get "/api/v1/guilds/#{guild.slug}/characters.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name level character_class_name race_name guild_role main_role_name].each do |attr|
          it "and contains character #{attr}" do
            expect(response.body).to have_json_path("characters/0/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guilds/999/characters.json', headers: headers
    end
  end

  describe 'POST#kick_character' do
    let!(:guild) { create :guild }
    let!(:character) { create :character, guild: guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let!(:gm) { create :character, guild: guild, user: user, world: guild.world }
      let!(:guild_role) { create :guild_role, guild: guild, character: gm, name: 'gm' }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { post '/api/v1/guilds/999/kick_character.json', params: { access_token: access_token, character_id: 999 } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        context 'for unexisted character' do
          before { post "/api/v1/guilds/#{guild.slug}/kick_character.json", params: { access_token: access_token, character_id: 999 } }

          it 'returns status 404' do
            expect(response.status).to eq 404
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed character' do
          let(:request) { post "/api/v1/guilds/#{guild.slug}/kick_character.json", params: { access_token: access_token, character_id: character.id } }

          it 'removes guild_id from character' do
            request
            character.reload

            expect(character.guild_id).to eq nil
          end

          it 'and calls CharacterLeftFromGuild' do
            expect(CharacterLeftFromGuild).to receive(:call).and_call_original

            request
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            it 'returns result message' do
              expect(JSON.parse(response.body)).to eq('result' => 'Character is kicked from guild')
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post "/api/v1/guilds/#{guild.id}/kick_character.json", params: { character_id: character.id }, headers: headers
    end
  end

  describe 'POST#leave_character' do
    let!(:guild) { create :guild }
    let!(:character) { create :character, guild: guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let!(:user_character) { create :character, guild: guild, user: user, world: guild.world }
      let!(:guild_role) { create :guild_role, guild: guild, character: user_character, name: 'gm' }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { post '/api/v1/guilds/999/leave_character.json', params: { access_token: access_token, character_id: 999 } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        context 'for unexisted character' do
          before { post "/api/v1/guilds/#{guild.slug}/leave_character.json", params: { access_token: access_token, character_id: 999 } }

          it 'returns status 404' do
            expect(response.status).to eq 404
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed character' do
          let(:request) { post "/api/v1/guilds/#{guild.slug}/leave_character.json", params: { access_token: access_token, character_id: user_character.id } }

          it 'removes guild_id from user_character' do
            request
            user_character.reload

            expect(user_character.guild_id).to eq nil
          end

          it 'and calls CharacterLeftFromGuild' do
            expect(CharacterLeftFromGuild).to receive(:call).and_call_original

            request
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            it 'returns result message' do
              expect(JSON.parse(response.body)).to eq('result' => 'Character is left from guild')
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post "/api/v1/guilds/#{guild.id}/leave_character.json", params: { character_id: character.id }, headers: headers
    end
  end

  describe 'GET#search' do
    let!(:guild) { create :guild, name: 'First' }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'without params' do
        let(:request) { get '/api/v1/guilds/search.json', params: { access_token: access_token, query: 'First' } }

        it 'calls search' do
          expect(Guild).to receive(:search).with('*First*', with: {}).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end

      context 'with world' do
        let(:request) { get '/api/v1/guilds/search.json', params: { access_token: access_token, query: 'First', world_id: guild.world_id } }

        it 'calls search' do
          expect(Guild).to receive(:search).with('*First*', with: { world_id: guild.world_id }).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end

      context 'with fraction' do
        let(:request) { get '/api/v1/guilds/search.json', params: { access_token: access_token, query: 'First', fraction_id: guild.fraction_id } }

        it 'calls search' do
          expect(Guild).to receive(:search).with('*First*', with: { fraction_id: guild.fraction_id }).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guilds/search.json', headers: headers
    end
  end

  describe 'GET#shcharacters_for_requestow' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { get '/api/v1/guilds/unexisted/characters_for_request.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        let!(:character1) { create :character, user: user }
        let!(:guild) { create :guild, world: character1.world, fraction: character1.race.fraction }
        let!(:character2) { create :character, user: user, guild: guild, world: character1.world, race: character1.race }
        let!(:character3) { create :character, user: user, world: character1.world, race: character1.race }
        let!(:guild_invite) { create :guild_invite, character: character3, guild: guild }
        before { get "/api/v1/guilds/#{guild.id}/characters_for_request.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        it 'returns only character without guild' do
          result = JSON.parse(response.body)

          expect(result['characters'].size).to eq 1
          expect(result['characters'][0]['id']).to eq character1.id
        end

        %w[id name].each do |attr|
          it "and contains character #{attr}" do
            expect(response.body).to have_json_path("characters/0/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guilds/unexisted/characters_for_request.json', headers: headers
    end
  end
end
