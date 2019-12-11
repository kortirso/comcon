RSpec.describe GuildsController, type: :controller do
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
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :show, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/404'
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

  describe 'GET#new' do
    let!(:guild) { create :guild }

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
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :edit, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed guild' do
        let!(:character) { create :character, guild: guild, world: guild.world, user: @current_user }
        let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

        it 'renders edit template' do
          get :edit, params: { locale: 'en', id: guild.slug }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'en', id: guild.slug }
    end
  end

  describe 'GET#management' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :management, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/404'
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

  describe 'GET#statics' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :statics, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed guild' do
        let!(:character) { create :character, guild: guild, world: guild.world, user: @current_user }
        let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

        it 'renders statics template' do
          get :statics, params: { locale: 'en', id: guild.slug }

          expect(response).to render_template :statics
        end
      end
    end

    def do_request
      get :statics, params: { locale: 'en', id: guild.slug }
    end
  end

  describe 'GET#notifications' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :notifications, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed guild' do
        let!(:character) { create :character, guild: guild, world: guild.world, user: @current_user }
        let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

        it 'renders notifications template' do
          get :notifications, params: { locale: 'en', id: guild.slug }

          expect(response).to render_template :notifications
        end
      end
    end

    def do_request
      get :notifications, params: { locale: 'en', id: guild.slug }
    end
  end

  describe 'GET#bank' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted guild' do
        it 'renders error template' do
          get :bank, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed guild' do
        let!(:character) { create :character, user: @current_user, guild: guild }

        it 'renders bank template' do
          get :bank, params: { locale: 'en', id: guild.slug }

          expect(response).to render_template :bank
        end
      end
    end

    def do_request
      get :bank, params: { locale: 'en', id: guild.slug }
    end
  end
end
