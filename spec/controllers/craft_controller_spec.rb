RSpec.describe CraftController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

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
end
