RSpec.describe 'Events API' do
  describe 'GET#index' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction }
      before { get '/api/v1/events.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id name date time slug].each do |attr|
        it "and contains event #{attr}" do
          expect(response.body).to have_json_path("events/0/#{attr}")
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/events.json', headers: headers
    end
  end

  describe 'GET#show' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction }
      before { get "/api/v1/events/#{world_event.id}.json", params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[user_characters characters].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get "/api/v1/events/#{event.id}.json", headers: headers
    end
  end

  describe 'GET#filter_values' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/events/filter_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[worlds fractions characters guilds].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/events/filter_values.json', headers: headers
    end
  end
end
