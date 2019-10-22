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

  describe 'GET#show' do
    let!(:event) { create :event }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user }
      let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction }

      context 'for unexisted event' do
        it 'renders error template' do
          get :show, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed event' do
        it 'renders show template' do
          get :show, params: { locale: 'en', id: world_event.slug }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { locale: 'en', id: event.slug }
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

        it 'calls CreateSubscribe' do
          expect(CreateSubscribe).to receive(:call).and_call_original

          request
        end

        it 'creates new event' do
          expect { request }.to change { character.owned_events.count }.by(1)
        end

        it 'and redirects to events path' do
          request

          expect(response).to redirect_to events_en_path
        end
      end
    end

    def do_request
      post :create, params: { locale: 'en', event: { name: '1', owner_id: 999, dungeon_id: dungeon.id, start_time: DateTime.now + 1.day } }
    end
  end
end
