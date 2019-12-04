RSpec.describe UsersController, type: :controller do
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
      get :index, params: { locale: 'en' }
    end
  end

  describe 'GET#edit' do
    let!(:user) { create :user }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted user' do
        it 'renders error template' do
          get :edit, params: { locale: 'ru', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed user' do
        it 'renders edit template' do
          get :edit, params: { locale: 'ru', id: user.id }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'en', id: user.id }
    end
  end

  describe 'PATCH#update' do
    let!(:user) { create :user }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted user' do
        let(:request) { patch :update, params: { locale: 'ru', id: 999, user: { role: 'user' } } }

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for invalid params' do
        let(:request) { patch :update, params: { locale: 'ru', id: user.id, user: { role: 'superadmin' } } }

        it 'does not update user' do
          request
          user.reload

          expect(user.role).to_not eq 'superadmin'
        end

        it 'and renders edit template' do
          request

          expect(response).to render_template :edit
        end
      end

      context 'for valid params' do
        let(:request) { patch :update, params: { locale: 'ru', id: user.id, user: { role: 'admin' } } }

        it 'updates new user' do
          request
          user.reload

          expect(user.role).to eq 'admin'
        end

        it 'and redirects to users path' do
          request

          expect(response).to redirect_to users_ru_path
        end
      end
    end

    def do_request
      patch :update, params: { locale: 'en', id: user.id, user: { role: 'user' } }
    end
  end

  describe 'DELETE#destroy' do
    let!(:user) { create :user }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted user' do
        let(:request) { delete :destroy, params: { locale: 'ru', id: 999 } }

        it 'does not delete any user' do
          expect { request }.to_not change(User, :count)
        end

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed user' do
        let(:request) { delete :destroy, params: { locale: 'ru', id: user.id } }

        it 'deletes user' do
          expect { request }.to change { User.count }.by(-1)
        end

        it 'and redirects to users path' do
          request

          expect(response).to redirect_to users_ru_path
        end
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en', id: user.id }
    end
  end

  describe 'GET #restore_password' do
    it 'renders restore_password template' do
      get :restore_password, params: { locale: 'ru' }

      expect(response).to render_template :restore_password
    end
  end

  describe 'POST #reset_password' do
    let!(:user) { create :user }

    context 'for unexisted user' do
      let(:request) { post :reset_password, params: { locale: 'ru', email: '1' } }

      it 'does not call Generating reset token' do
        expect(GenerateResetToken).to_not receive(:call)

        request
      end

      it 'and renders error template' do
        request

        expect(response).to render_template 'shared/error'
      end
    end

    context 'for too many requests' do
      let(:request) { post :reset_password, params: { locale: 'ru', email: user.email } }
      before { user.update(reset_password_token_sent_at: DateTime.now) }

      it 'does not call Generating reset token' do
        expect(GenerateResetToken).to_not receive(:call)

        request
      end

      it 'and renders error template' do
        request

        expect(response).to render_template 'shared/error'
      end
    end

    context 'for existed user' do
      let(:request) { post :reset_password, params: { locale: 'ru', email: user.email } }

      it 'calls Generating reset token' do
        expect(GenerateResetToken).to receive(:call)

        request
      end

      it 'and redirects to root path' do
        request

        expect(response).to redirect_to root_ru_path
      end
    end
  end

  describe 'GET #new_password' do
    let!(:user) { create :user }

    context 'for unexisted user' do
      it 'render error' do
        get :new_password, params: { locale: 'ru' }

        expect(response).to render_template 'shared/error'
      end
    end

    context 'for existed user without token' do
      it 'render error' do
        get :new_password, params: { locale: 'ru', email: 'something@gmail.com' }

        expect(response).to render_template 'shared/error'
      end
    end

    context 'for existed user with incorrect token' do
      it 'render error' do
        get :new_password, params: { locale: 'ru', email: user.email, reset_password_token: '123456' }

        expect(response).to render_template 'shared/error'
      end
    end

    context 'for existed user with correct email and token' do
      let!(:user) { create :user, reset_password_token: SecureRandom.urlsafe_base64.to_s }

      it 'render #new_password' do
        get :new_password, params: { locale: 'ru', email: user.email, reset_password_token: user.reset_password_token }

        expect(response).to render_template :new_password
      end
    end
  end

  describe 'PATCH #change_password' do
    context 'for unexisted user' do
      let!(:user) { create :user }
      before { patch :change_password, params: { locale: 'ru', email: 'test@gmail.com', user: { password: '123456qwer', password_confirmation: '123456qwer' }, reset_password_token: '123456' } }

      it 'does not change password' do
        user.reload

        expect(user.valid_password?('123456qwer')).to eq false
      end

      it 'and render error' do
        expect(response).to render_template 'shared/error'
      end
    end

    context 'for existed user' do
      let!(:user) { create :user, reset_password_token: SecureRandom.urlsafe_base64.to_s }

      context 'with incorrect params' do
        before { patch :change_password, params: { locale: 'ru', email: user.email, user: { password: '123456qwer', password_confirmation: '123456qwer' }, reset_password_token: '123456' } }

        it 'does not change password' do
          user.reload

          expect(user.valid_password?('123456qwer')).to eq false
        end

        it 'and render error' do
          expect(response).to render_template 'shared/error'
        end
      end

      context 'with different passwords' do
        before { patch :change_password, params: { locale: 'ru', email: user.email, user: { password: '1', password_confirmation: '12' }, reset_password_token: user.reset_password_token } }

        it 'does not change password' do
          user.reload

          expect(user.valid_password?('1')).to eq false
        end

        it 'and redirects to new_password_users_ru_path' do
          expect(response).to redirect_to new_password_users_ru_path(email: user.email, reset_password_token: user.reset_password_token)
        end
      end

      context 'with short passwords' do
        before { patch :change_password, params: { locale: 'ru', email: user.email, user: { password: '12', password_confirmation: '12' }, reset_password_token: user.reset_password_token } }

        it 'does not change password' do
          user.reload

          expect(user.valid_password?('12')).to eq false
        end

        it 'and redirects to new_password_users_ru_path' do
          expect(response).to redirect_to new_password_users_ru_path(email: user.email, reset_password_token: user.reset_password_token)
        end
      end

      context 'with correct params' do
        before { patch :change_password, params: { locale: 'ru', email: user.email, user: { password: '123456qwer', password_confirmation: '123456qwer' }, reset_password_token: user.reset_password_token } }

        it 'change password' do
          user.reload

          expect(user.valid_password?('123456qwer')).to eq true
        end

        it 'and redirects to root path' do
          expect(response).to redirect_to root_ru_path
        end
      end
    end
  end
end
