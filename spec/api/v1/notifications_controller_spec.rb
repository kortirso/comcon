RSpec.describe 'Notifications API' do
  describe 'GET#index' do
    let!(:notifications) { create_list(:notification, 3) }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/notifications.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name event status].each do |attr|
        it "and contains notification #{attr}" do
          expect(response.body).to have_json_path("notifications/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/notifications.json', headers: headers
    end
  end
end
