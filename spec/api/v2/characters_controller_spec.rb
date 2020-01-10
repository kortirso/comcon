RSpec.describe 'Characters API' do
  describe 'PATCH#update' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted character' do
        before { patch '/api/v2/characters/unknown/transfer.json', params: { access_token: access_token, character: { name: '1' } } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed character' do
        let!(:race) { create :race, :human }
        let!(:character_class) { create :character_class, :warrior }
        let!(:world) { create :world }
        let!(:guild) { create :guild, fraction: race.fraction }
        let!(:character) { create :character, user: user, guild: guild, race: race, world: guild.world }
        let!(:combination) { create :combination, combinateable: character.race, character_class: character.character_class }
        let!(:role) { create :role }
        let!(:world_fraction) { create :world_fraction, world: world, fraction: race.fraction }
        let!(:combination) { create :combination, combinateable: race, character_class: character_class }

        context 'for invalid params' do
          let(:request) { patch "/api/v2/characters/#{character.id}/transfer.json", params: { access_token: access_token, character: { name: '', main_role_id: role.id, roles: { role.id.to_s => '1' } } } }

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
          let(:request) { patch "/api/v2/characters/#{character.id}/transfer.json", params: { access_token: access_token, character: { name: '123', main_role_id: role.id, roles: { role.id.to_s => '1' }, race_id: race.id, character_class_id: character_class.id, world_id: world.id } } }

          it 'updates character' do
            request
            character.reload

            expect(character.name).to eq '123'
            expect(character.race_id).to eq race.id
            expect(character.character_class_id).to eq character_class.id
            expect(character.world_id).to eq world.id
          end

          it 'and calls ComplexTransferCharacter' do
            expect(ComplexTransferCharacter).to receive(:call).and_call_original

            request
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
      patch '/api/v2/characters/999/transfer.json', headers: headers
    end
  end

  describe 'post#equipment' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted character' do
        before { post '/api/v2/characters/unknown/equipment.json', params: { access_token: access_token, character: { name: '1' } } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed character' do
        let!(:race) { create :race, :human }
        let!(:character_class) { create :character_class, :warrior }
        let!(:world) { create :world }
        let!(:guild) { create :guild, fraction: race.fraction }
        let!(:character) { create :character, user: user, guild: guild, race: race, world: guild.world }
        let!(:combination) { create :combination, combinateable: character.race, character_class: character.character_class }
        let!(:role) { create :role }
        let!(:world_fraction) { create :world_fraction, world: world, fraction: race.fraction }
        let!(:combination) { create :combination, combinateable: race, character_class: character_class }
        let(:request) { post "/api/v2/characters/#{character.id}/equipment.json", params: { access_token: access_token, value: '8176:;12039:;10774:;49:;13110:16;5609:;9624:;2033:;9857:;10777:;10710:;2933:;0:0;0:0;4114:;10823:;6829:;3108:;23192:;' } }

        it 'calls CharacterEquipmentUpload' do
          expect(CharacterEquipmentUpload).to receive(:call).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Equipment is uploaded')
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v2/characters/999/equipment.json', headers: headers
    end
  end
end
