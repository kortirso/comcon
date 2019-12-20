RSpec.describe WelcomeController, type: :controller do
  describe 'GET#index' do
    it 'renders index template' do
      get :index, params: { locale: 'en' }

      expect(response).to render_template :index
    end
  end

  describe 'GET#donate' do
    it 'renders donate template' do
      get :donate, params: { locale: 'en' }

      expect(response).to render_template :donate
    end
  end

  describe 'GET#privacy' do
    it 'renders privacy template' do
      get :privacy, params: { locale: 'en' }

      expect(response).to render_template :privacy
    end
  end
end
