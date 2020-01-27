RSpec.describe 'Subscribes API' do
  describe 'GET#index' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:event) { create :event, eventable: guild }
      let!(:subscribe) { create :subscribe, subscribeable: event, character: character, status: 3 }
      before { get '/api/v2/subscribes/closest.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[status event character].each do |attr|
        it "and contains subscribe #{attr}" do
          expect(response.body).to have_json_path("subscribes/data/0/attributes/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v2/subscribes/closest.json', headers: headers
    end
  end

  describe 'DELETE#destroy' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:role) { create :role, :tank }
      let!(:character_role) { create :character_role, character: character, role: role }
      let!(:subscribe) { create :subscribe, subscribeable: event, character: character, status: 'signed' }

      context 'for unexisted subscribe' do
        before { delete '/api/v2/subscribes/999.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for event subscribe' do
        let(:request) { delete "/api/v2/subscribes/#{subscribe.id}.json", params: { access_token: access_token } }

        it 'destroyes subscribe' do
          expect { request }.to change { Subscribe.count }.by(-1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Subscribe is deleted')
          end
        end
      end

      context 'for static subscribe' do
        let!(:static) { create :static, staticable: character }
        let!(:group_role) { create :group_role, groupable: static }
        let!(:subscribe) { create :subscribe, subscribeable: static, character: character, status: 'reserve' }
        let(:request) { delete "/api/v2/subscribes/#{subscribe.id}.json", params: { access_token: access_token } }

        context 'in answer' do
          before { request }

          it 'returns status 403' do
            expect(response.status).to eq 403
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Access is forbidden')
          end
        end
      end
    end

    def do_request(headers = {})
      delete '/api/v2/subscribes/999.json', headers: headers
    end
  end
end
