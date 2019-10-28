RSpec.describe GuildsController, type: :controller do
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

  describe 'GET#show' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :show, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed guild' do
        it 'renders show template' do
          get :show, params: { locale: 'en', id: guild.slug }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { locale: 'en', id: guild.slug }
    end
  end
end
