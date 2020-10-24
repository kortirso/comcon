# frozen_string_literal: true

RSpec.describe 'Recipes API' do
  describe 'GET#index' do
    let!(:recipes) { create_list(:recipe, 2) }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'
    it_behaves_like 'API auth admins'

    context 'with valid admin token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      before { get '/api/v2/recipes.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[name links skill profession_id].each do |attr|
        it "and contains recipe #{attr}" do
          expect(response.body).to have_json_path("recipes/data/0/attributes/#{attr}")
        end
      end
    end

    def do_request(headers={})
      get '/api/v2/recipes.json', headers: headers
    end
  end
end
