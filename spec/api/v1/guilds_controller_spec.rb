RSpec.describe 'Guilds API' do
  describe 'GET#index' do
    let!(:guild) { create :guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/guilds.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name full_name fraction world slug].each do |attr|
        it "and contains guild #{attr}" do
          expect(response.body).to have_json_path("guilds/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/guilds.json', headers: headers
    end
  end

  describe 'GET#characters' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { get '/api/v1/guilds/999/characters.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        let!(:guild) { create :guild }
        let!(:character) { create :character, guild: guild }
        before { get "/api/v1/guilds/#{guild.slug}/characters.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name level character_class race guild_role].each do |attr|
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

  describe 'GET#characters' do
    let!(:guild) { create :guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let!(:gm) { create :character, guild: guild, user: user, world: guild.world }
      let!(:guild_role) { create :guild_role, guild: guild, character: gm, name: 'gm' }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { get '/api/v1/guilds/999/kick_character.json', params: { access_token: access_token, character_id: 999 } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        context 'for unexisted character' do
          before { get "/api/v1/guilds/#{guild.slug}/kick_character.json", params: { access_token: access_token, character_id: 999 } }

          it 'returns status 400' do
            expect(response.status).to eq 400
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed character' do
          let!(:character) { create :character, guild: guild }
          let(:request) { get "/api/v1/guilds/#{guild.slug}/kick_character.json", params: { access_token: access_token, character_id: character.id } }

          it 'removes guild_id from character' do
            request
            character.reload

            expect(character.guild_id).to eq nil
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
      get '/api/v1/guilds/999/characters.json', headers: headers
    end
  end
end
