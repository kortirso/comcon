RSpec.describe 'Craft API' do
  describe 'GET#filter_values' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/craft/filter_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[worlds fractions guilds recipes professions].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/craft/filter_values.json', headers: headers
    end
  end

  describe 'GET#search' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:recipe) { create :recipe }
      let!(:character_profession) { create :character_profession, character: character, profession: recipe.profession }
      let!(:character_recipe) { create :character_recipe, recipe: recipe, character_profession: character_profession }
      before { get '/api/v1/craft/search.json', params: { access_token: access_token, recipe_id: recipe.id } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name level character_class race guild].each do |attr|
        it "and contains event #{attr}" do
          expect(response.body).to have_json_path("characters/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/craft/search.json', headers: headers
    end
  end
end
