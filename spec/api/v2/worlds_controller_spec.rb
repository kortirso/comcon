# frozen_string_literal: true

RSpec.describe 'Worlds API' do
  describe 'GET#index' do
    let!(:worlds) { create_list(:world, 3) }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      before { get '/api/v2/worlds.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[name zone].each do |attr|
        it "and contains world #{attr}" do
          expect(response.body).to have_json_path("worlds/data/0/attributes/#{attr}")
        end
      end
    end

    def do_request(headers={})
      get '/api/v2/worlds.json', headers: headers
    end
  end
end
