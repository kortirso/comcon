RSpec.describe 'Character classes API' do
  describe 'GET#index' do
    let!(:warrior) { create :character_class, :warrior }
    let!(:shaman) { create :character_class, :shaman }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/character_classes.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name].each do |attr|
        it "and contains race #{attr}" do
          expect(response.body).to have_json_path("character_classes/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/character_classes.json', headers: headers
    end
  end
end
