# frozen_string_literal: true

RSpec.describe Users::RegistrationsController, type: :controller do
  describe 'POST#create' do
    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    context 'for different passwords' do
      let(:req) { post :create, params: { locale: 'en', user: { email: '', password: '1234567890', password_confirmation: '123' } } }

      it 'does not create new user' do
        expect { req }.not_to change(User, :count)
      end

      it 'and renders new template' do
        req

        expect(response).to render_template :new
      end
    end

    context 'for existed user' do
      let!(:user) { create :user }
      let(:req) { post :create, params: { locale: 'en', user: { email: user.email, password: '1234567890', password_confirmation: '1234567890' } } }

      it 'does not create new user' do
        expect { req }.not_to change(User, :count)
      end

      it 'and renders new template' do
        req

        expect(response).to render_template :new
      end
    end

    context 'for short password' do
      let(:req) { post :create, params: { locale: 'en', user: { email: 'something@gmail.com', password: '1', password_confirmation: '1' } } }

      it 'does not create new user' do
        expect { req }.not_to change(User, :count)
      end

      it 'and renders new template' do
        req

        expect(response).to render_template :new
      end
    end

    context 'for invalid data' do
      let(:req) { post :create, params: { locale: 'en', user: { email: 'something@yandex.ru', password: '1234567890', password_confirmation: '123456789' } } }

      it 'does not create new user' do
        expect { req }.not_to change(User, :count)
      end

      it 'and renders new template' do
        req

        expect(response).to render_template :new
      end
    end

    context 'for valid data' do
      let(:req) { post :create, params: { locale: 'en', user: { email: 'something@yandex.ru', password: '1234567890', password_confirmation: '1234567890' } } }

      it 'creates new user' do
        expect { req }.to change(User, :count).by(1)
      end

      it 'and redirects to root path' do
        req

        expect(response).to redirect_to root_en_path
      end
    end
  end
end
