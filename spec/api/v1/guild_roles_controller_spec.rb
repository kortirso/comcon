RSpec.describe 'GuildRoles API' do
  describe 'POST#create' do
    let!(:race) { create :race, :human }
    let!(:guild) { create :guild, fraction: race.fraction }
    let!(:character) { create :character, guild: guild, race: race }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let(:request) { post '/api/v1/guild_roles.json', params: { access_token: access_token, guild_role: { name: '', guild_id: guild.id, character_id: character.id } } }

        it 'does not create new guild role' do
          expect { request }.to_not change(GuildRole, :count)
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
        let(:request) { post '/api/v1/guild_roles.json', params: { access_token: access_token, guild_role: { name: 'gm', guild_id: guild.id, character_id: character.id } } }

        it 'and creates new guild role' do
          expect { request }.to change { GuildRole.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id name].each do |attr|
            it "and contains guild_role #{attr}" do
              expect(response.body).to have_json_path("guild_role/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/guild_roles.json', params: { guild_role: { name: '' } }, headers: headers
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild role' do
        before { patch '/api/v1/guild_roles/unknown.json', params: { access_token: access_token, character: { name: '1' } } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed character' do
        let!(:guild) { create :guild }
        let!(:character) { create :character, guild: guild }
        let!(:guild_role) { create :guild_role, guild: guild, character: character }

        context 'for invalid params' do
          let(:request) { patch "/api/v1/guild_roles/#{guild_role.id}.json", params: { access_token: access_token, guild_role: { name: '' } } }

          it 'does not update character' do
            request
            guild_role.reload

            expect(guild_role.name).to_not eq ''
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
          let(:request) { patch "/api/v1/guild_roles/#{guild_role.id}.json", params: { access_token: access_token, guild_role: { name: 'rl' } } }

          it 'and updates guild_role' do
            request
            guild_role.reload

            expect(guild_role.name).to eq 'rl'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id name].each do |attr|
              it "and contains guild_role #{attr}" do
                expect(response.body).to have_json_path("guild_role/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      patch '/api/v1/characters/999.json', params: { guild_role: { name: '' } }, headers: headers
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild role' do
        let!(:request) { delete '/api/v1/guild_roles/unknown.json', params: { access_token: access_token } }

        it 'does not delete guild role' do
          expect { request }.to_not change(GuildRole, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 400' do
            expect(response.status).to eq 400
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end
      end

      context 'for existed guild role' do
        let!(:guild_role) { create :guild_role }
        let(:request) { delete "/api/v1/guild_roles/#{guild_role.id}.json", params: { access_token: access_token } }

        it 'deletes guild role' do
          expect { request }.to change { GuildRole.count }.by(-1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns success message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Success')
          end
        end
      end
    end

    def do_request(headers = {})
      delete '/api/v1/guild_roles/unknown.json', headers: headers
    end
  end
end
