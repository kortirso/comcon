# frozen_string_literal: true

RSpec.describe 'Activities API' do
  describe 'GET#index' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }
      let!(:activity) { create :activity, guild: guild }

      before { get '/api/v2/activities.json', params: { access_token: access_token } }

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[title description].each do |attr|
        it "and contains activity #{attr}" do
          expect(response.body).to have_json_path("activities/data/0/attributes/#{attr}")
        end
      end
    end

    def do_request(headers={})
      get '/api/v2/activities.json', headers: headers
    end
  end

  describe 'GET#show' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted activity' do
        before { get '/api/v2/activities/unknown.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed activity' do
        let!(:guild) { create :guild }
        let!(:character) { create :character, guild: guild, user: user }
        let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }
        let!(:activity) { create :activity, guild: guild }

        before { get "/api/v2/activities/#{activity.id}.json", params: { access_token: access_token } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[title description].each do |attr|
          it "and contains delivery #{attr}" do
            expect(response.body).to have_json_path("activity/data/attributes/#{attr}")
          end
        end
      end
    end

    def do_request(headers={})
      get '/api/v2/activities/999.json', headers: headers
    end
  end

  describe 'POST#create' do
    let!(:guild) { create :guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        let(:request) { post '/api/v2/activities.json', params: { access_token: access_token, activity: { guild_id: 'unexisted', title: '1', description: '2' } } }

        it 'does not create new activity' do
          expect { request }.not_to change(Activity, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 404' do
            expect(response.status).to eq 404
          end

          it 'and returns errors' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end
      end

      context 'for existed deliveriable with rights' do
        let!(:character) { create :character, guild: guild, user: user }
        let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }

        context 'for invalid params' do
          let(:request) { post '/api/v2/activities.json', params: { access_token: access_token, activity: { guild_id: guild.id, title: '', description: '2' } } }

          it 'does not create new activity' do
            expect { request }.not_to change(Activity, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 409' do
              expect(response.status).to eq 409
            end

            it 'and returns errors' do
              expect(JSON.parse(response.body)['errors']).not_to eq nil
            end
          end
        end

        context 'for valid params' do
          let(:request) { post '/api/v2/activities.json', params: { access_token: access_token, activity: { guild_id: guild.id, title: '1', description: '2' } } }

          it 'creates new activity' do
            expect { request }.to change { guild.activities.count }.by(1)
          end

          it 'and calls CreateActivityNotificationJob' do
            expect(CreateActivityNotificationJob).to receive(:perform_later).and_call_original

            request
          end

          context 'in answer' do
            before { request }

            it 'returns status 201' do
              expect(response.status).to eq 201
            end

            %w[title description].each do |attr|
              it "and contains delivery #{attr}" do
                expect(response.body).to have_json_path("activity/data/attributes/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers={})
      post '/api/v2/activities.json', params: { activity: { guild_id: guild.id } }, headers: headers
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted activity' do
        before { patch '/api/v2/activities/unknown.json', params: { access_token: access_token, activity: { title: '1' } } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed activity' do
        let!(:guild) { create :guild }
        let!(:character) { create :character, guild: guild, user: user }
        let!(:guild_role) { create :guild_role, character: character, guild: guild, name: 'gm' }
        let!(:activity) { create :activity, guild: guild }

        context 'for invalid params' do
          let(:request) { patch "/api/v2/activities/#{activity.id}.json", params: { access_token: access_token, activity: { title: '' } } }

          it 'does not update activity' do
            request
            activity.reload

            expect(activity.title).not_to eq ''
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
          let(:request) { patch "/api/v2/activities/#{activity.id}.json", params: { access_token: access_token, activity: { title: '1' } } }

          it 'updates activity' do
            request
            activity.reload

            expect(activity.title).to eq '1'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[title description].each do |attr|
              it "and contains delivery #{attr}" do
                expect(response.body).to have_json_path("activity/data/attributes/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers={})
      patch '/api/v2/activities/999.json', headers: headers
    end
  end
end
