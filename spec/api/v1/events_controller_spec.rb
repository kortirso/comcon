# frozen_string_literal: true

RSpec.describe 'Events API' do
  describe 'GET#show' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }

      context 'for unexisted event' do
        before { get '/api/v1/events/unexisted.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed event' do
        let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction }

        before { get "/api/v1/events/#{world_event.id}.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name description date time fraction_name dungeon_name owner_name eventable_type eventable_name group_role].each do |attr|
          it "and contains event #{attr}" do
            expect(response.body).to have_json_path("event/#{attr}")
          end
        end
      end
    end

    def do_request(headers={})
      get "/api/v1/events/#{event.id}.json", headers: headers
    end
  end

  describe 'POST#create' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:guild) { create :guild }
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for invalid params' do
        let!(:character) { create :character, user: user, guild: guild }
        let!(:dungeon) { create :dungeon }
        let(:request) { post '/api/v1/events.json', params: { access_token: access_token, event: { name: '123', owner_id: character.id, dungeon_id: dungeon.id, start_time: (DateTime.now - 1.day).to_i, eventable_type: 'Guild' } } }

        it 'does not create new event' do
          expect { request }.not_to change(Event, :count)

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
        let!(:character) { create :character, user: user, guild: guild }
        let!(:role) { create :role, :tank }
        let!(:character_role) { create :character_role, character: character, role: role }
        let!(:dungeon) { create :dungeon }
        let(:request) { post '/api/v1/events.json', params: { access_token: access_token, event: { name: '123', owner_id: character.id, dungeon_id: dungeon.id, start_time: (DateTime.now + 1.day).to_i, eventable_type: 'Guild' } } }

        before do
          allow(CreateEventNotificationJob).to receive(:perform_later)
          allow(Subscribes::ForEvent::CreateService).to receive(:call)
          allow(CreateGroupRole).to receive(:call)
        end

        it 'creates new event' do
          expect { request }.to change { character.owned_events.count }.by(1)

          request
        end

        it 'and calls CreateEventNotificationJob' do
          request

          expect(CreateEventNotificationJob).to have_received(:perform_later)
        end

        it 'and calls Subscribes::ForEvent::CreateService' do
          request

          expect(Subscribes::ForEvent::CreateService).to have_received(:call)
        end

        it 'and calls CreateGroupRole' do
          request

          expect(CreateGroupRole).to have_received(:call)
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

      context 'for valid params, many times' do
        let!(:character) { create :character, user: user, guild: guild }
        let!(:role) { create :role, :tank }
        let!(:character_role) { create :character_role, character: character, role: role }
        let!(:dungeon) { create :dungeon }
        let(:request) { post '/api/v1/events.json', params: { access_token: access_token, event: { name: '123', owner_id: character.id, dungeon_id: dungeon.id, start_time: (DateTime.now + 1.day).to_i, eventable_type: 'Guild', repeat: 2, repeat_days: 7 } } }

        it 'creates new events' do
          expect { request }.to change { character.owned_events.count }.by(3)

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          it 'and returns message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Events are created')
          end
        end
      end
    end

    def do_request(headers={})
      post '/api/v1/events.json', params: { event: { name: '1' } }, headers: headers
    end
  end

  describe 'GET#edit' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }

      context 'for unexisted event' do
        before { get '/api/v1/events/unexisted/edit.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed event' do
        let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction }

        before { get "/api/v1/events/#{world_event.id}/edit.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id name date time slug fraction_id description dungeon_id owner_id event_type eventable_type group_role].each do |attr|
          it "and contains event #{attr}" do
            expect(response.body).to have_json_path("event/#{attr}")
          end
        end
      end
    end

    def do_request(headers={})
      get "/api/v1/events/#{event.id}/edit.json", headers: headers
    end
  end

  describe 'PATCH#update' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:guild) { create :guild }
      let!(:user) { create :user }
      let!(:character) { create :character, user: user, guild: guild }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted event' do
        before { patch '/api/v1/events/unexisted.json', params: { access_token: access_token, event: { name: '123' } } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed event' do
        let!(:world_event) { create :event, fraction: character.race.fraction, owner: character }
        let!(:group_role) { create :group_role, groupable: world_event }

        context 'for invalid params' do
          let(:request) { patch "/api/v1/events/#{world_event.id}.json", params: { access_token: access_token, event: { name: '' } } }

          it 'does not update event' do
            request
            world_event.reload

            expect(world_event.name).not_to eq ''
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
          let(:request) { patch "/api/v1/events/#{world_event.id}.json", params: { access_token: access_token, event: { name: 'NEW Cool', dungeon_id: world_event.dungeon_id, start_time: event.start_time.to_i } } }

          it 'and calls UpdateGroupRole' do
            expect(UpdateGroupRole).to receive(:call).and_call_original

            request
          end

          it 'and updates event' do
            request
            world_event.reload

            expect(world_event.name).to eq 'NEW Cool'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id name date time slug fraction_id description dungeon_id owner_id event_type eventable_type].each do |attr|
              it "and contains event #{attr}" do
                expect(response.body).to have_json_path("event/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers={})
      patch "/api/v1/events/#{event.id}.json", params: { event: { name: '1' } }, headers: headers
    end
  end

  describe 'DELETE#destroy' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:character) { create :character, user: user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted event' do
        before { delete '/api/v1/events/unexisted.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed event' do
        let!(:world_event) { create :event, eventable: character.world, fraction: character.race.fraction, owner: character }
        let(:request) { delete "/api/v1/events/#{world_event.id}.json", params: { access_token: access_token } }

        it 'deletes event' do
          expect { request }.to change(Event, :count).by(-1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Event is destroyed')
          end
        end
      end
    end

    def do_request(headers={})
      delete "/api/v1/events/#{event.id}.json", headers: headers
    end
  end

  describe 'GET#event_form_values' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:static) { create :static, staticable: character }
      let!(:static_member) { create :static_member, character: character, static: static }

      before { get '/api/v1/events/event_form_values.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[characters dungeons statics group_roles].each do |attr|
        it "and contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end
    end

    def do_request(headers={})
      get '/api/v1/events/event_form_values.json', headers: headers
    end
  end
end
