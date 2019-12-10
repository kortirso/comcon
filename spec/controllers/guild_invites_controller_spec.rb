RSpec.describe GuildInvitesController, type: :controller do
  describe 'GET#find' do
    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'without user characters' do
        it 'renders find template' do
          get :find, params: { locale: 'en' }

          expect(response).to render_template :find
        end
      end

      context 'with user characters' do
        let!(:character) { create :character, user: @current_user }

        it 'renders find template' do
          get :find, params: { locale: 'en' }

          expect(response).to render_template :find
        end
      end
    end

    def do_request
      get :find, params: { locale: 'en' }
    end
  end
end
