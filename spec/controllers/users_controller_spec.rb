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
      get :index, params: { locale: 'ru' }
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
      get :edit, params: { locale: 'ru', id: user.id }
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
      patch :update, params: { locale: 'ru', id: user.id, user: { role: 'user' } }
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
      delete :destroy, params: { locale: 'ru', id: user.id }
    end
  end
end
