RSpec.describe 'Events API' do
  describe 'GET#index' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction }
      let!(:subscribe) { create :subscribe, character: character, subscribeable: world_event }

      context 'without params' do
        before { get '/api/v2/events.json', params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[name slug description fraction_id dungeon_id event_type eventable_type eventable_id owner_id date time group_role status].each do |attr|
          it "and contains event #{attr}" do
            expect(response.body).to have_json_path("events/data/0/attributes/#{attr}")
          end
        end
      end

      context 'with day params' do
        let(:time) { Time.now - 7.days }
        before { get '/api/v2/events.json', params: { year: time.year, month: time.month, day: time.day, days: 14, access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[name slug description fraction_id dungeon_id event_type eventable_type eventable_id owner_id date time group_role status].each do |attr|
          it "and contains event #{attr}" do
            expect(response.body).to have_json_path("events/data/0/attributes/#{attr}")
          end
        end
      end

      context 'with unexisted character id' do
        before { get '/api/v2/events.json', params: { character_id: 'unexisted', access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[name slug description fraction_id dungeon_id event_type eventable_type eventable_id owner_id date time group_role status].each do |attr|
          it "and contains event #{attr}" do
            expect(response.body).to have_json_path("events/data/0/attributes/#{attr}")
          end
        end
      end

      context 'with existed character id' do
        before { get '/api/v2/events.json', params: { character_id: character.id, access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[name slug description fraction_id dungeon_id event_type eventable_type eventable_id owner_id date time group_role status].each do |attr|
          it "and contains event #{attr}" do
            expect(response.body).to have_json_path("events/data/0/attributes/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v2/events.json', headers: headers
    end
  end

  describe 'GET#filter_values' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      before { get '/api/v2/events/filter_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[fractions characters guilds statics dungeons].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers = {})
      get '/api/v2/events/filter_values.json', headers: headers
    end
  end

  describe 'GET#subscribers' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }

      context 'for unexisted event' do
        before { get '/api/v2/events/unexisted/subscribers.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed event' do
        let!(:world_event) { create :event, fraction: character.race.fraction }
        let!(:subscribe) { create :subscribe, subscribeable: world_event, character: character }
        before { get "/api/v2/events/#{world_event.id}/subscribers.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id status comment character for_role].each do |attr|
          it "and contains subscribe #{attr}" do
            expect(response.body).to have_json_path("subscribers/data/0/attributes/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get "/api/v2/events/#{event.id}/subscribers.json", headers: headers
    end
  end
end
