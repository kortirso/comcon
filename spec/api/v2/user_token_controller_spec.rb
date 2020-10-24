# frozen_string_literal: true

RSpec.describe 'UserToken API' do
  describe 'POST#create' do
    context 'without params' do
      before { post '/api/v2/user_token.json', params: {} }

      it 'returns status 401' do
        expect(response.status).to eq 401
      end

      it 'and contains error message' do
        expect(JSON.parse(response.body)).to eq('errors' => 'No auth strategy found')
      end
    end

    context 'for email params' do
      context 'for invalid params' do
        before { post '/api/v2/user_token.json', params: { email: '1@gmail.com', password: '1234567890' } }

        it 'returns status 401' do
          expect(response.status).to eq 401
        end

        it 'and contains error message' do
          expect(JSON.parse(response.body)).to eq('errors' => 'Authorization error')
        end
      end

      context 'for valid params' do
        let!(:user) { create :user }

        before { post '/api/v2/user_token.json', params: { email: user.email, password: user.password } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id email].each do |attr|
          it "and contains user #{attr}" do
            expect(response.body).to have_json_path("user/#{attr}")
          end
        end

        %w[access_token expires_at].each do |attr|
          it "and contains #{attr}" do
            expect(response.body).to have_json_path(attr.to_s)
          end
        end

        %w[password password_confirmation].each do |attr|
          it "and does not contain user #{attr}" do
            expect(response.body).not_to have_json_path("user/#{attr}")
          end
        end
      end
    end
  end
end
