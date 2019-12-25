RSpec.describe ActivitiesController, type: :controller do
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

  describe 'GET#new' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'without guild param' do
        it 'renders error page' do
          get :new, params: { locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'with guild param' do
        context 'for unexisted guild' do
          it 'renders error page' do
            get :new, params: { locale: 'en', guild_id: 'unexisted' }

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existed guild' do
          context 'for permitted guild' do
            it 'renders error page' do
              get :new, params: { locale: 'en', guild_id: guild.id }

              expect(response).to render_template 'shared/403'
            end
          end

          context 'for valid guild' do
            let!(:character) { create :character, guild: guild, user: @current_user }
            let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }

            it 'renders new template' do
              get :new, params: { locale: 'en', guild_id: guild.id }

              expect(response).to render_template :new
            end
          end
        end
      end
    end

    def do_request
      get :new, params: { locale: 'en', guild_id: guild.id }
    end
  end
end
