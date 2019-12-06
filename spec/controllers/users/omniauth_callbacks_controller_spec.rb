RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  it { should use_before_action :provides_callback }

  describe 'discord' do
    context 'without info from provider' do
      before :each do
        request.env['devise.mapping'] = Devise.mappings[:user]
        request.env['omniauth.auth'] = nil
      end
      before { get 'discord', params: { locale: 'en' } }

      it 'redirects to root path' do
        expect(response).to redirect_to root_en_path
      end

      it 'and sets flash message with error' do
        expect(request.flash[:error]).to eq 'Access is forbidden'
      end
    end

    context 'without email in info from provider' do
      before :each do
        request.env['devise.mapping'] = Devise.mappings[:user]
        request.env['omniauth.auth'] = facebook_invalid_hash
      end
      before { get 'discord', params: { locale: 'en' } }

      it 'redirects to root path' do
        expect(response).to redirect_to root_en_path
      end

      it 'and sets flash message with manifesto_username' do
        expect(request.flash[:manifesto_username]).to eq true
      end
    end

    context 'with info from provider' do
      before :each do
        request.env['devise.mapping'] = Devise.mappings[:user]
        request.env['omniauth.auth'] = discord_hash
      end

      context 'for new user' do
        before { get 'discord', params: { locale: 'en' } }

        it 'redirects to user path' do
          expect(response).to redirect_to root_en_path
        end
      end

      context 'for existed user' do
        let!(:user) { create :user, email: 'example_discord@xyze.it' }

        it 'redirects to user path' do
          get 'discord', params: { locale: 'en' }

          expect(response).to redirect_to root_en_path
        end
      end
    end
  end
end
