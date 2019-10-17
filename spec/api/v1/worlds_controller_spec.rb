RSpec.describe 'Worlds API' do
  describe 'GET#index' do
    let!(:world) { create :world }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/worlds.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name].each do |attr|
        it "and contains world #{attr}" do
          expect(response.body).to have_json_path("worlds/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/worlds.json', headers: headers
    end
  end
end
