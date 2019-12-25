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

  describe 'GET#edit' do
    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted activity' do
        it 'renders error template' do
          get :edit, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed activity' do
        let!(:guild) { create :guild }
        let!(:character) { create :character, guild: guild, user: @current_user }
        let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }
        let!(:activity) { create :activity, guild: guild }

        it 'renders edit template' do
          get :edit, params: { locale: 'en', id: activity.id }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'en', id: 999 }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted activity' do
        let(:request) { delete :destroy, params: { locale: 'en', id: 999 } }

        it 'does not delete any activity' do
          expect { request }.to_not change(Activity, :count)
        end

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed activity' do
        let!(:guild) { create :guild }
        let!(:character) { create :character, guild: guild, user: @current_user }
        let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }
        let!(:activity) { create :activity, guild: guild }
        let(:request) { delete :destroy, params: { locale: 'en', id: activity.id } }

        it 'deletes activity' do
          expect { request }.to change { Activity.count }.by(-1)
        end

        it 'and redirects to characters path' do
          request

          expect(response).to redirect_to activities_guild_en_path(guild.slug)
        end
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en', id: 999 }
    end
  end
end
