RSpec.describe GuildsController, type: :controller do
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
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :show, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed guild' do
        it 'renders show template' do
          get :show, params: { locale: 'en', id: guild.slug }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { locale: 'en', id: guild.slug }
    end
  end

  describe 'GET#management' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :management, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed guild' do
        let!(:character) { create :character, guild: guild, world: guild.world, user: @current_user }
        let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

        it 'renders management template' do
          get :management, params: { locale: 'en', id: guild.slug }

          expect(response).to render_template :management
        end
      end
    end

    def do_request
      get :management, params: { locale: 'en', id: guild.slug }
    end
  end
end
