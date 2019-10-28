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
end
