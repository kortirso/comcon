RSpec.describe RecipesController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      it 'renders index template' do
        get :index, params: { locale: 'ru' }

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index, params: { locale: 'ru' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      it 'renders new template' do
        get :new, params: { locale: 'ru' }

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new, params: { locale: 'ru' }
    end
  end

  describe 'GET#edit' do
    let!(:recipe) { create :recipe }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted recipe' do
        it 'renders error template' do
          get :edit, params: { locale: 'ru', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed recipe' do
        it 'renders edit template' do
          get :edit, params: { locale: 'ru', id: recipe.id }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'ru', id: recipe.id }
    end
  end

  describe 'DELETE#destroy' do
    let!(:recipe) { create :recipe }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted recipe' do
        let(:request) { delete :destroy, params: { locale: 'ru', id: 999 } }

        it 'does not delete any recipe' do
          expect { request }.to_not change(Recipe, :count)
        end

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed recipe' do
        let(:request) { delete :destroy, params: { locale: 'ru', id: recipe.id } }

        it 'deletes recipe' do
          expect { request }.to change { Recipe.count }.by(-1)
        end

        it 'and redirects to recipes path' do
          request

          expect(response).to redirect_to recipes_ru_path
        end
      end
    end

    def do_request
      delete :destroy, params: { locale: 'ru', id: recipe.id }
    end
  end
end
