RSpec.describe EmailConfirmationsController, type: :controller do
  describe 'GET #index' do
    context 'for invalid email' do
      it 'renders shared#error' do
        get :index, params: { locale: 'ru', email: 'something@gmail.com' }

        expect(response).to render_template 'shared/error'
      end
    end

    context 'for user without confirmation token' do
      let!(:user) { create :user }

      it 'renders shared#error' do
        get :index, params: { locale: 'ru', email: user.email, confirmation_token: '' }

        expect(response).to render_template 'shared/error'
      end
    end

    context 'for valid user' do
      let!(:user) { create :user, :unconfirmed }

      context 'for invalid token' do
        it 'renders shared#error' do
          get :index, params: { locale: 'ru', email: user.email, confirmation_token: 'something' }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for valid token' do
        it 'redirects to root path' do
          get :index, params: { locale: 'ru', email: user.email, confirmation_token: user.confirmation_token }

          expect(response).to redirect_to root_ru_path
        end
      end
    end
  end
end
