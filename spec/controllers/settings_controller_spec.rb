RSpec.describe SettingsController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      it 'renders index template' do
        get :index, params: { locale: 'ru' }

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end

  describe 'GET#external_services' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      it 'renders external_services template' do
        get :external_services, params: { locale: 'ru' }

        expect(response).to render_template :external_services
      end
    end

    def do_request
      get :external_services, params: { locale: 'en' }
    end
  end
end
