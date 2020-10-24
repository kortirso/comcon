# frozen_string_literal: true

RSpec.describe 'GameItemCategories API' do
  describe 'GET#index' do
    let!(:game_item_categories) { create_list(:game_item_category, 3) }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      before { get '/api/v1/game_item_categories.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end
    end

    def do_request(headers={})
      get '/api/v1/game_item_categories.json', headers: headers
    end
  end
end
