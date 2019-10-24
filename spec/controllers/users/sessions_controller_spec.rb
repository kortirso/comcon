RSpec.describe Users::SessionsController, type: :controller do
  before(:each) { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'POST#create' do
    let!(:user) { create :user }

    context 'for invalid data' do
      before { post :create, params: { user: { email: user.email, password: '11111' } } }

      it 'redirects new login template' do
        expect(response).to render_template :new
      end
    end

    context 'for valid data' do
      before { post :create, params: { user: { email: user.email, password: user.password } } }

      it 'redirects to root path' do
        expect(response).to redirect_to root_ru_path
      end
    end
  end
end
