# frozen_string_literal: true

RSpec.describe 'UserSettings API' do
  describe 'GET#index' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      before { get '/api/v1/user_settings.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[time_offset].each do |attr|
        it "and contains user #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers={})
      get '/api/v1/user_settings.json', headers: headers
    end
  end

  describe 'PATCH#update_settings' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let(:request) { patch '/api/v1/user_settings/update_settings.json', params: { access_token: access_token, user_settings: { time_offset: { id: 1, value: '' } } } }

      it 'calls UpdateTimeOffset' do
        expect(UpdateTimeOffset).to receive(:call).and_call_original

        request
      end

      context 'in answer' do
        before { request }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        it 'and returns success message' do
          expect(JSON.parse(response.body)).to eq('result' => 'User settings are updated')
        end
      end
    end

    def do_request(headers={})
      patch '/api/v1/user_settings/update_settings.json', headers: headers
    end
  end

  describe 'PATCH#update_password' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let(:request) { patch '/api/v1/user_settings/update_password.json', params: { access_token: access_token, user_settings: { password: '1234567890', password_confirmation: '' } } }

        it 'calls UpdateUserPassword' do
          expect(UpdateUserPassword).to receive(:call).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 409' do
            expect(response.status).to eq 409
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)['errors']).not_to eq nil
          end
        end
      end

      context 'for valid params' do
        let(:request) { patch '/api/v1/user_settings/update_password.json', params: { access_token: access_token, user_settings: { password: '1234567890', password_confirmation: '1234567890' } } }

        it 'calls UpdateUserPassword' do
          expect(UpdateUserPassword).to receive(:call).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns success message' do
            expect(JSON.parse(response.body)).to eq('result' => 'User password is updated')
          end
        end
      end
    end

    def do_request(headers={})
      patch '/api/v1/user_settings/update_password.json', headers: headers
    end
  end
end
