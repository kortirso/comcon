RSpec.describe 'Characters API' do
  describe 'GET#show' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

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

        %w[id name level character_class_id race_id guild_id main_role_id dungeon_ids secondary_role_ids profession_ids].each do |attr|
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
    let!(:combination) { create :combination, combinateable: race, character_class: character_class }
    let!(:world) { create :world }
    let!(:role) { create :role }
    let!(:world_fraction) { create :world_fraction, world: world, fraction: race.fraction }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let(:request) { post '/api/v1/characters.json', params: { access_token: access_token, character: { name: '', level: -1, race_id: race.id, character_class_id: character_class.id, world_id: world.id, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' }, professions: { '1' => '0' } } } }

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
        let(:request) { post '/api/v1/characters.json', params: { access_token: access_token, character: { name: '134', level: 1, race_id: race.id, character_class_id: character_class.id, world_id: world.id, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' }, professions: { '1' => '0' } } } }

        it 'calls CreateCharacterRoles' do
          expect(CreateCharacterRoles).to receive(:call).and_call_original

          request
        end

        it 'and calls CreateDungeonAccess' do
          expect(CreateDungeonAccess).to receive(:call).and_call_original

          request
        end

        it 'and calls CreateCharacterProfessions' do
          expect(CreateCharacterProfessions).to receive(:call).and_call_original

          request
        end

        it 'and creates new character' do
          expect { request }.to change { user.characters.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id name level character_class_name race_name guild_name user_id].each do |attr|
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
    it_behaves_like 'API auth unconfirmed'

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
        let!(:character) { create :character, user: user, guild: guild, race: race, world: guild.world }
        let!(:combination) { create :combination, combinateable: character.race, character_class: character.character_class }
        let!(:role) { create :role }

        context 'for invalid params' do
          let(:request) { patch "/api/v1/characters/#{character.id}.json", params: { access_token: access_token, character: { name: '', level: -1, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' }, professions: { '1' => '0' } } } }

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
          let(:request) { patch "/api/v1/characters/#{character.id}.json", params: { access_token: access_token, character: { name: '123', level: 1, main_role_id: role.id, roles: { role.id.to_s => '1' }, dungeon: { '1' => '0' }, professions: { '1' => '0' } } } }

          it 'calls CreateCharacterRoles' do
            expect(CreateCharacterRoles).to receive(:call).and_call_original

            request
          end

          it 'and calls CreateDungeonAccess' do
            expect(CreateDungeonAccess).to receive(:call).and_call_original

            request
          end

          it 'and calls CreateCharacterProfessions' do
            expect(CreateCharacterProfessions).to receive(:call).and_call_original

            request
          end

          it 'and updates character' do
            request
            character.reload

            expect(character.name).to eq '123'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id name level character_class_name race_name guild_name user_id].each do |attr|
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
    let!(:race) { create :race, :human }
    let!(:character_class) { create :character_class }
    let!(:combination) { create :combination, character_class: character_class, combinateable: race }
    let!(:role) { create :role }
    let!(:combination) { create :combination, character_class: character_class, combinateable: role }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/characters/default_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[races worlds dungeons professions].each do |attr|
        it "and contains character #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/characters/default_values.json', headers: headers
    end
  end

  describe 'GET#search' do
    let!(:character) { create :character, name: 'First' }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'without params' do
        let(:request) { get '/api/v1/characters/search.json', params: { access_token: access_token, query: 'First' } }

        it 'calls search' do
          expect(Character).to receive(:search).with('*First*', with: {}).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end

      context 'with world' do
        let(:request) { get '/api/v1/characters/search.json', params: { access_token: access_token, query: 'First', world_id: character.world_id } }

        it 'calls search' do
          expect(Character).to receive(:search).with('*First*', with: { world_id: character.world_id }).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end

      context 'with character_class' do
        let(:request) { get '/api/v1/characters/search.json', params: { access_token: access_token, query: 'First', character_class_id: character.character_class_id } }

        it 'calls search' do
          expect(Character).to receive(:search).with('*First*', with: { character_class_id: character.character_class_id }).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end

      context 'with race' do
        let(:request) { get '/api/v1/characters/search.json', params: { access_token: access_token, query: 'First', race_id: character.race_id } }

        it 'calls search' do
          expect(Character).to receive(:search).with('*First*', with: { race_id: character.race_id }).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end

      context 'with fraction' do
        let(:request) { get '/api/v1/characters/search.json', params: { access_token: access_token, query: 'First', fraction_id: character.race.fraction_id } }

        it 'calls search' do
          expect(Character).to receive(:search).with('*First*', with: { race_id: character.race.fraction.races.pluck(:id) }).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/characters/search.json', headers: headers
    end
  end

  describe 'GET#upload_recipes' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted character' do
        before { post '/api/v1/characters/unknown/upload_recipes.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed character' do
        let!(:character) { create :character, user: user }

        context 'for unexisted profession' do
          before { post "/api/v1/characters/#{character.id}/upload_recipes.json", params: { access_token: access_token, profession_id: 'unexisted' } }

          it 'returns status 400' do
            expect(response.status).to eq 400
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed profession' do
          let!(:profession) { create :profession }

          context 'for unexisted character profession' do
            let(:request) { post "/api/v1/characters/#{character.id}/upload_recipes.json", params: { access_token: access_token, profession_id: profession.id, value: 'ruRU;Хорошее зелье маны' } }

            it 'calls CharacterRecipesUpload' do
              expect(CharacterRecipesUpload).to receive(:call).and_call_original

              request
            end

            context 'in answer' do
              before { request }

              it 'returns status 409' do
                expect(response.status).to eq 409
              end

              it 'and returns result message' do
                expect(JSON.parse(response.body)).to eq('result' => 'Recipes are not uploaded')
              end
            end
          end

          context 'for existed character profession' do
            let!(:character_profession) { create :character_profession, character: character, profession: profession }
            let(:request) { post "/api/v1/characters/#{character.id}/upload_recipes.json", params: { access_token: access_token, profession_id: profession.id, value: 'ruRU;Хорошее зелье маны' } }

            it 'calls CharacterRecipesUpload' do
              expect(CharacterRecipesUpload).to receive(:call).and_call_original

              request
            end

            context 'in answer' do
              before { request }

              it 'returns status 200' do
                expect(response.status).to eq 200
              end

              it 'and returns result message' do
                expect(JSON.parse(response.body)).to eq('result' => 'Recipes are uploaded')
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/characters/unknown/upload_recipes.json', headers: headers
    end
  end
end
