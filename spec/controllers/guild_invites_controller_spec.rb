RSpec.describe GuildInvitesController, type: :controller do
  describe 'GET#new' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'without guild or character param' do
        it 'renders error page' do
          get :new, params: { locale: 'en' }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'with guild param' do
        context 'for unexisted guild' do
          it 'renders error page' do
            get :new, params: { locale: 'en', guild_id: 'unexisted' }

            expect(response).to render_template 'shared/error'
          end
        end

        context 'for existed guild' do
          context 'for permitted guild' do
            it 'renders error page' do
              get :new, params: { locale: 'en', guild_id: guild.id }

              expect(response).to render_template 'shared/error'
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

      context 'with character param' do
        context 'for unexisted character' do
          it 'renders error page' do
            get :new, params: { locale: 'en', character_id: 'unexisted' }

            expect(response).to render_template 'shared/error'
          end
        end

        context 'for existed character' do
          context 'for not user character' do
            let!(:character) { create :character }

            it 'renders error page' do
              get :new, params: { locale: 'en', character_id: character.id }

              expect(response).to render_template 'shared/error'
            end
          end

          context 'for character with guild' do
            let!(:guild) { create :guild }
            let!(:character) { create :character, guild: guild, user: @current_user }

            it 'renders error page' do
              get :new, params: { locale: 'en', character_id: character.id }

              expect(response).to render_template 'shared/error'
            end
          end

          context 'for valid character' do
            let!(:character) { create :character, user: @current_user, guild_id: nil }

            it 'renders new template' do
              get :new, params: { locale: 'en', character_id: character.id }

              expect(response).to render_template :new
            end
          end
        end
      end
    end

    def do_request
      get :new, params: { locale: 'en', deliveriable_id: guild.id, deliveriable_type: 'Guild' }
    end
  end
end