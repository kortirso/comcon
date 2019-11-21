RSpec.describe EventsController, type: :controller do
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

  describe 'GET#show' do
    let!(:event) { create :event }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

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
    it_behaves_like 'Unconfirmed User Auth'

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

  describe 'GET#edit' do
    let!(:event) { create :event }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user }
      let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction, owner: character }

      context 'for unexisted event' do
        it 'renders error template' do
          get :edit, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed event' do
        it 'renders edit template' do
          get :edit, params: { locale: 'en', id: world_event.slug }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'en', id: event.slug }
    end
  end
end
