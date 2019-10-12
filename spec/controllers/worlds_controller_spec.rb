RSpec.describe WorldsController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      it 'renders index template' do
        get :index

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index
    end
  end

  describe 'GET#new' do
    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      it 'renders new template' do
        get :new

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new
    end
  end

  describe 'POST#create' do
    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for invalid params' do
        let(:request) { post :create, params: { world: { name: '', zone: '' } } }

        it 'does not create new world' do
          expect { request }.to_not change(World, :count)
        end

        it 'and renders new template' do
          request

          expect(response).to render_template :new
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { world: { name: '1', zone: '2' } } }

        it 'creates new world' do
          expect { request }.to change { World.count }.by(1)
        end

        it 'and redirects to worlds path' do
          request

          expect(response).to redirect_to worlds_path
        end
      end
    end

    def do_request
      post :create, params: { world: { name: '', zone: '' } }
    end
  end

  describe 'GET#edit' do
    let!(:world) { create :world }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted world' do
        it 'renders error template' do
          get :edit, params: { id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed world' do
        it 'renders edit template' do
          get :edit, params: { id: world.id }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { id: world.id }
    end
  end

  describe 'PATCH#update' do
    let!(:world) { create :world }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted world' do
        let(:request) { patch :update, params: { id: 999, world: { name: '', zone: '' } } }

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for invalid params' do
        let(:request) { patch :update, params: { id: world.id, world: { name: '', zone: '' } } }

        it 'does not update new world' do
          request
          world.reload

          expect(world.name).to_not eq ''
        end

        it 'and renders edit template' do
          request

          expect(response).to render_template :edit
        end
      end

      context 'for valid params' do
        let(:request) { patch :update, params: { id: world.id, world: { name: '1', zone: '2' } } }

        it 'updates new world' do
          request
          world.reload

          expect(world.name).to eq '1'
        end

        it 'and redirects to worlds path' do
          request

          expect(response).to redirect_to worlds_path
        end
      end
    end

    def do_request
      patch :update, params: { id: world.id, world: { name: '1', zone: '2' } }
    end
  end

  describe 'DELETE#destroy' do
    let!(:world) { create :world }

    it_behaves_like 'Admin Auth'

    context 'for logged admin' do
      sign_in_admin

      context 'for unexisted world' do
        let(:request) { delete :destroy, params: { id: 999 } }

        it 'does not delete any world' do
          expect { request }.to_not change(World, :count)
        end

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed world' do
        let(:request) { delete :destroy, params: { id: world.id } }

        it 'deletes world' do
          expect { request }.to change { World.count }.by(-1)
        end

        it 'and redirects to worlds path' do
          request

          expect(response).to redirect_to worlds_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: world.id }
    end
  end
end
