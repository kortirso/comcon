RSpec.describe 'Recipes API' do
  describe 'GET#index' do
    let!(:recipes) { create_list(:recipe, 2) }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth admins'

    context 'with valid admin token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/recipes.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name links skill profession_id].each do |attr|
        it "and contains recipe #{attr}" do
          expect(response.body).to have_json_path("recipes/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/recipes.json', headers: headers
    end
  end

  describe 'GET#show' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth admins'

    context 'with valid admin token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted recipe' do
        before { get '/api/v1/recipes/unknown.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed recipe' do
        let!(:recipe) { create :recipe }
        before { get "/api/v1/recipes/#{recipe.id}.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name links skill profession_id].each do |attr|
          it "and contains recipe #{attr}" do
            expect(response.body).to have_json_path("recipe/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/recipes/999.json', headers: headers
    end
  end

  describe 'POST#create' do
    let!(:profession) { create :profession }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth admins'

    context 'with valid admin token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let(:request) { post '/api/v1/recipes.json', params: { access_token: access_token, recipe: { name: { 'en' => '', 'ru' => '' }, profession_id: profession.id, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1 } } }

        it 'does not create new recipe' do
          expect { request }.to_not change(Recipe, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 409' do
            expect(response.status).to eq 409
          end

          it 'and returns errors' do
            expect(JSON.parse(response.body)['errors']).to_not eq nil
          end
        end
      end

      context 'for valid params' do
        let(:request) { post '/api/v1/recipes.json', params: { access_token: access_token, recipe: { name: { 'en' => 'Plans: Sulfuron Hammer', 'ru' => 'Чертеж: сульфуронский молот' }, profession_id: profession.id, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1 } } }

        it 'creates new recipe' do
          expect { request }.to change { Recipe.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id name links skill profession_id].each do |attr|
            it "and contains recipe #{attr}" do
              expect(response.body).to have_json_path("recipe/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/recipes.json', params: { recipe: { name: '' } }, headers: headers
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth admins'

    context 'with valid user token in params' do
      let!(:user) { create :user, :admin }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted recipe' do
        before { patch '/api/v1/recipes/unknown.json', params: { access_token: access_token, recipe: { name: '1' } } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed character' do
        let!(:recipe) { create :recipe }

        context 'for invalid params' do
          let(:request) { patch "/api/v1/recipes/#{recipe.id}.json", params: { access_token: access_token, recipe: { skill: 500 } } }

          it 'does not update recipe' do
            request
            recipe.reload

            expect(recipe.skill).to_not eq 500
          end

          context 'in answer' do
            before { request }

            it 'returns status 409' do
              expect(response.status).to eq 409
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)['errors']).to_not eq nil
            end
          end
        end

        context 'for valid params' do
          let(:request) { patch "/api/v1/recipes/#{recipe.id}.json", params: { access_token: access_token, recipe: { name: { 'en' => '111', 'ru' => '222' } } } }

          it 'updates recipe' do
            request
            recipe.reload

            expect(recipe.name).to eq('en' => '111', 'ru' => '222')
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id name links skill profession_id].each do |attr|
              it "and contains recipe #{attr}" do
                expect(response.body).to have_json_path("recipe/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      patch '/api/v1/recipes/999.json', params: { recipe: { name: '' } }, headers: headers
    end
  end

  describe 'GET#search' do
    let!(:recipe) { create :recipe, name: { 'en' => 'Something', 'ru' => 'Что-то' } }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'without params' do
        let(:request) { get '/api/v1/recipes/search.json', params: { access_token: access_token, query: 'Somet' } }

        it 'calls search' do
          expect(Recipe).to receive(:search).with('*Somet*', with: {}).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end

      context 'with profession' do
        let(:request) { get '/api/v1/recipes/search.json', params: { access_token: access_token, query: 'Somet', profession_id: recipe.profession_id } }

        it 'calls search' do
          expect(Recipe).to receive(:search).with('*Somet*', with: { profession_id: recipe.profession_id }).and_call_original

          request
        end

        it 'and returns status 200' do
          request

          expect(response.status).to eq 200
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/recipes/search.json', headers: headers
    end
  end
end
