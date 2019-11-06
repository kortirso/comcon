RSpec.describe DeliveriesController, type: :controller do
  describe 'GET#new' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'without deliveriable param' do
        it 'renders error page' do
          get :new, params: { locale: 'en' }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'with deliveriable param' do
        context 'for unexisted deliveriable' do
          it 'renders error page' do
            get :new, params: { locale: 'en', deliveriable_id: 'unexisted', deliveriable_type: 'Guild' }

            expect(response).to render_template 'shared/error'
          end
        end

        context 'for existed deliveriable' do
          context 'for permitted deliveriable' do
            it 'renders error page' do
              get :new, params: { locale: 'en', deliveriable_id: guild.id, deliveriable_type: 'Guild' }

              expect(response).to render_template 'shared/error'
            end
          end

          context 'for valid guild' do
            let!(:character) { create :character, guild: guild, user: @current_user }
            let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }

            it 'renders new template' do
              get :new, params: { locale: 'en', deliveriable_id: guild.id, deliveriable_type: 'Guild' }

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

  describe 'DELETE#destroy' do
    let!(:guild) { create :guild }
    let!(:delivery) { create :delivery, deliveriable: guild }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user, guild: guild }

      context 'for unexisted delivery' do
        it 'renders error page' do
          delete :destroy, params: { locale: 'en', id: 'unexisted' }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed delivery' do
        context 'for invalid access' do
          let(:request) { delete :destroy, params: { locale: 'en', id: delivery.id } }

          it 'does not delete delivery' do
            expect { request }.to_not change(Delivery, :count)
          end

          it 'and renders error page' do
            request

            expect(response).to render_template 'shared/error'
          end
        end

        context 'for valid access' do
          let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
          let(:request) { delete :destroy, params: { locale: 'en', id: delivery.id } }

          it 'deletes delivery' do
            expect { request }.to change { Delivery.count }.by(-1)
          end

          it 'and redirects to guild management page' do
            request

            expect(response).to redirect_to management_guild_en_path(guild.slug)
          end
        end
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en', id: delivery.id }
    end
  end
end
