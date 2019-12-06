RSpec.describe StaticsController, type: :controller do
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
    let!(:static) { create :static, staticable: guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user, guild: guild }

      context 'for unexisted static' do
        it 'renders error page' do
          get :show, params: { locale: 'en', id: 'unexisted' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed static' do
        let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

        it 'renders show template' do
          get :show, params: { locale: 'en', id: static.slug }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { locale: 'en', id: static.slug }
    end
  end

  describe 'GET#new' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'without guild param' do
        it 'renders new template' do
          get :new, params: { locale: 'en' }

          expect(response).to render_template :new
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
          let!(:guild) { create :guild }

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
              get :new, params: { locale: 'en', guild: guild.id }

              expect(response).to render_template :new
            end
          end
        end
      end
    end

    def do_request
      get :new, params: { locale: 'en' }
    end
  end

  describe 'GET#edit' do
    let!(:guild) { create :guild }
    let!(:static) { create :static, staticable: guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user, guild: guild }

      context 'for unexisted static' do
        it 'renders error page' do
          get :edit, params: { locale: 'en', id: 'unexisted' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed static' do
        context 'for invalid access' do
          it 'renders error page' do
            get :edit, params: { locale: 'en', id: static.slug }

            expect(response).to render_template 'shared/403'
          end
        end

        context 'for valid access' do
          let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

          it 'renders edit template' do
            get :edit, params: { locale: 'en', id: static.slug }

            expect(response).to render_template :edit
          end
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'en', id: static.slug }
    end
  end

  describe 'DELETE#destroy' do
    let!(:guild) { create :guild }
    let!(:static) { create :static, staticable: guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user, guild: guild }

      context 'for unexisted static' do
        it 'renders error page' do
          delete :destroy, params: { locale: 'en', id: 'unexisted' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed static' do
        context 'for invalid access' do
          let(:request) { delete :destroy, params: { locale: 'en', id: static.slug } }

          it 'does not delete static' do
            expect { request }.to_not change(Static, :count)
          end

          it 'and renders error page' do
            request

            expect(response).to render_template 'shared/403'
          end
        end

        context 'for valid access' do
          let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
          let(:request) { delete :destroy, params: { locale: 'en', id: static.slug } }

          it 'deletes static' do
            expect { request }.to change { Static.count }.by(-1)
          end

          it 'and redirects to guild management page' do
            request

            expect(response).to redirect_to statics_guild_en_path(guild.slug)
          end
        end
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en', id: static.slug }
    end
  end

  describe 'GET#management' do
    let!(:guild) { create :guild }
    let!(:static) { create :static, staticable: guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user, guild: guild }

      context 'for unexisted static' do
        it 'renders error page' do
          get :management, params: { locale: 'en', id: 'unexisted' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed static' do
        context 'for invalid access' do
          it 'renders error page' do
            get :management, params: { locale: 'en', id: static.slug }

            expect(response).to render_template 'shared/403'
          end
        end

        context 'for valid access' do
          let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

          it 'renders management template' do
            get :management, params: { locale: 'en', id: static.slug }

            expect(response).to render_template :management
          end
        end
      end
    end

    def do_request
      get :management, params: { locale: 'en', id: static.slug }
    end
  end
end
