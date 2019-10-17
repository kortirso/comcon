RSpec.describe CharactersController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      it 'renders index template' do
        get :index, params: { locale: 'en' }

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      it 'renders new template' do
        get :new, params: { locale: 'en' }

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new, params: { locale: 'en' }
    end
  end

  describe 'GET#edit' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted character' do
        it 'renders error template' do
          get :edit, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed character' do
        let!(:character) { create :character, :human_warrior, user: @current_user }

        it 'renders edit template' do
          get :edit, params: { locale: 'en', id: character.id }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'en', id: 999 }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted character' do
        let(:request) { delete :destroy, params: { locale: 'en', id: 999 } }

        it 'does not delete any character' do
          expect { request }.to_not change(Character, :count)
        end

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed character' do
        let!(:character) { create :character, :human_warrior, user: @current_user }
        let(:request) { delete :destroy, params: { locale: 'en', id: character.id } }

        it 'deletes character' do
          expect { request }.to change { Character.count }.by(-1)
        end

        it 'and redirects to characters path' do
          request

          expect(response).to redirect_to characters_en_path
        end
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en', id: 999 }
    end
  end
end
