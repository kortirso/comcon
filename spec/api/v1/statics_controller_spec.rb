RSpec.describe 'Statics API' do
  describe 'POST#create' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        let(:request) { post '/api/v1/statics.json', params: { access_token: access_token, static: { name: '123', staticable_type: 'Guild', staticable_id: 'unexisted', description: '123' } } }

        it 'does not create new static' do
          expect { request }.to_not change(Static, :count)

          request
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

      context 'for invalid params' do
        let(:request) { post '/api/v1/statics.json', params: { access_token: access_token, static: { name: '', staticable_type: 'Guild', staticable_id: guild.id, description: '123' } } }

        it 'does not create new event' do
          expect { request }.to_not change(Event, :count)

          request
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
        let(:request) { post '/api/v1/statics.json', params: { access_token: access_token, static: { name: '123', staticable_type: 'Guild', staticable_id: guild.id, description: '123' } } }

        it 'creates new static' do
          expect { request }.to change { guild.statics.count }.by(1)

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id name description staticable_id staticable_type guild_slug].each do |attr|
            it "and contains #{attr}" do
              expect(response.body).to have_json_path("static/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/statics.json', params: { static: { name: '1' } }, headers: headers
    end
  end

  describe 'GET#form_values' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/statics/form_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[characters guilds].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/statics/form_values.json', headers: headers
    end
  end
end
