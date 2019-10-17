RSpec.describe 'Roles API' do
  describe 'GET#index' do
    let!(:role) { create :role }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/roles.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name].each do |attr|
        it "and contains role #{attr}" do
          expect(response.body).to have_json_path("roles/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/roles.json', headers: headers
    end
  end
end
