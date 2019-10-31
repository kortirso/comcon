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

  describe 'POST#create' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let!(:character) { create :character, user: user }
        let!(:dungeon) { create :dungeon }
        let(:request) { post '/api/v1/events.json', params: { access_token: access_token, event: { name: '123', owner_id: character.id, dungeon_id: dungeon.id, start_time: (DateTime.now - 1.day).to_i, eventable_type: 'World' } } }

        it 'does not create new event' do
          expect { request }.to_not change(Event, :count)

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 409' do
            expect(response.status).to eq 409
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)['errors']).to_not eq nil
          end
        end
      end

      context 'for valid params' do
        let!(:character) { create :character, user: user }
        let!(:dungeon) { create :dungeon }
        let(:request) { post '/api/v1/events.json', params: { access_token: access_token, event: { name: '123', owner_id: character.id, dungeon_id: dungeon.id, start_time: (DateTime.now + 1.day).to_i, eventable_type: 'World' } } }

        it 'creates new event' do
          expect { request }.to change { character.owned_events.count }.by(1)

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id name date time slug fraction_id].each do |attr|
            it "and contains #{attr}" do
              expect(response.body).to have_json_path("event/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/events.json', params: { event: { name: '1' } }, headers: headers
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

  describe 'GET#event_form_values' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v1/events/event_form_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[characters dungeons].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/events/event_form_values.json', headers: headers
    end
  end
end
