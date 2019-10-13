RSpec.describe EventsController, type: :controller do
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

  describe 'POST#create' do
    let!(:dungeon) { create :dungeon }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for invalid params' do
        let(:request) { post :create, params: { locale: 'en', event: { name: '' } } }

        it 'does not create new event' do
          expect { request }.to_not change(Event, :count)
        end

        it 'and renders new template' do
          request

          expect(response).to render_template :new
        end
      end

      context 'for valid params' do
        let!(:character) { create :character, user: @current_user }
        let(:request) { post :create, params: { locale: 'en', event: { name: '1', owner_id: character.id, dungeon_id: dungeon.id, start_time: DateTime.now + 1.day, eventable_type: 'World' } } }

        it 'creates new event' do
          expect { request }.to change { character.events.count }.by(1)
        end

        it 'and redirects to characters path' do
          request

          expect(response).to redirect_to root_en_path
        end
      end
    end

    def do_request
      post :create, params: { locale: 'en', event: { name: '1', owner_id: 999, dungeon_id: dungeon.id, start_time: DateTime.now + 1.day } }
    end
  end
end
