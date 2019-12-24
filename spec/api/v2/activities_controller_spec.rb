RSpec.describe 'Activities API' do
  describe 'POST#create' do
    let!(:guild) { create :guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        let(:request) { post '/api/v2/activities.json', params: { access_token: access_token, activity: { guild_id: 'unexisted', title: '1', description: '2' } } }

        it 'does not create new activity' do
          expect { request }.to_not change(Activity, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 404' do
            expect(response.status).to eq 404
          end

          it 'and returns errors' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end
      end

      context 'for existed deliveriable with rights' do
        let!(:character) { create :character, guild: guild, user: user }
        let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }

        context 'for invalid params' do
          let(:request) { post '/api/v2/activities.json', params: { access_token: access_token, activity: { guild_id: guild.id, title: '', description: '2' } } }

          it 'does not create new activity' do
            expect { request }.to_not change(Activity, :count)
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
          let(:request) { post '/api/v2/activities.json', params: { access_token: access_token, activity: { guild_id: guild.id, title: '1', description: '2' } } }

          it 'and creates new activity' do
            expect { request }.to change { guild.activities.count }.by(1)
          end

          context 'in answer' do
            before { request }

            it 'returns status 201' do
              expect(response.status).to eq 201
            end

            %w[title description].each do |attr|
              it "and contains delivery #{attr}" do
                expect(response.body).to have_json_path("activity/data/attributes/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v2/activities.json', params: { activity: { guild_id: guild.id } }, headers: headers
    end
  end
end
