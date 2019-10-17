RSpec.describe 'Characters API' do
  describe 'GET#show' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted character' do
        before { get '/api/v1/characters/unknown.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed character' do
        let!(:character) { create :character, user: user }
        before { get "/api/v1/characters/#{character.id}.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name level character_class race guild main_role dungeons secondary_roles].each do |attr|
          it "and contains character #{attr}" do
            expect(response.body).to have_json_path("character/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/characters/999.json', headers: headers
    end
  end

  describe 'POST#create' do
    let!(:race) { create :race, :human }
    let!(:character_class) { create :character_class, :warrior }
    let!(:guild) { create :guild, fraction: race.fraction }
    let!(:role) { create :role }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let(:request) { post '/api/v1/characters.json', params: { access_token: access_token, character: { name: '', level: -1, race_id: race.id, character_class_id: character_class.id, guild_id: guild.id, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' } } } }

        it 'does not create new character' do
          expect { request }.to_not change(Character, :count)
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
        let(:request) { post '/api/v1/characters.json', params: { access_token: access_token, character: { name: '1', level: 1, race_id: race.id, character_class_id: character_class.id, guild_id: guild.id, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' } } } }

        it 'creates new character' do
          expect { request }.to change { user.characters.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id name level character_class race guild subscribe_for_event main_role user_id].each do |attr|
            it "and contains character #{attr}" do
              expect(response.body).to have_json_path("character/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/characters.json', headers: headers
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted character' do
        before { patch '/api/v1/characters/unknown.json', params: { access_token: access_token, character: { name: '1' } } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed character' do
        let!(:race) { create :race, :human }
        let!(:guild) { create :guild, fraction: race.fraction }
        let!(:character) { create :character, user: user, guild: guild, race: race }
        let!(:role) { create :role }

        context 'for invalid params' do
          let(:request) { patch "/api/v1/characters/#{character.id}.json", params: { access_token: access_token, character: { name: '', level: -1, race_id: character.race_id, character_class_id: character.character_class_id, guild_id: character.guild_id, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' } } } }

          it 'does not update character' do
            request
            character.reload

            expect(character.name).to_not eq ''
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
          let(:request) { patch "/api/v1/characters/#{character.id}.json", params: { access_token: access_token, character: { name: '1', level: 1, race_id: character.race_id, character_class_id: character.character_class_id, guild_id: character.guild_id, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' } } } }

          it 'updates character' do
            request
            character.reload

            expect(character.name).to eq '1'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id name level character_class race guild subscribe_for_event main_role user_id].each do |attr|
              it "and contains character #{attr}" do
                expect(response.body).to have_json_path("character/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      patch '/api/v1/characters/999.json', headers: headers
    end
  end

  describe 'GET#default_values' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/characters/default_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[races character_classes guilds worlds roles dungeons].each do |attr|
        it "and contains character #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/characters/default_values.json', headers: headers
    end
  end
end
