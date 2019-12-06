RSpec.describe 'Subscribes API' do
  describe 'POST#create' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:role) { create :role, :tank }
      let!(:character_role) { create :character_role, character: character, role: role }

      context 'for invalid params' do
        let(:request) { post '/api/v1/subscribes.json', params: { subscribe: { event_id: nil }, access_token: access_token } }

        it 'does not create new subscribe' do
          expect { request }.to_not change(Subscribe, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 404' do
            expect(response.status).to eq 404
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end
      end

      context 'for valid params' do
        let(:request) { post '/api/v1/subscribes.json', params: { subscribe: { event_id: event.id, character_id: character.id, status: 'signed' }, access_token: access_token } }

        it 'creates new subscribe' do
          expect { request }.to change { character.subscribes.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id status comment character].each do |attr|
            it "and contains subscribe #{attr}" do
              expect(response.body).to have_json_path("subscribe/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/subscribes.json', params: { subscribe: { event_id: event.id, character_id: nil, status: 'signed' } }, headers: headers
    end
  end

  describe 'PATCH#update' do
    let!(:event) { create :event }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
      let!(:character) { create :character, user: user }
      let!(:role) { create :role, :tank }
      let!(:character_role) { create :character_role, character: character, role: role }
      let!(:subscribe) { create :subscribe, event: event, character: character, status: 'signed' }

      context 'for unexisted subscribe' do
        before { patch '/api/v1/subscribes/999.json', params: { subscribe: { status: 'approved' }, access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for invalid params' do
        let(:request) { patch "/api/v1/subscribes/#{subscribe.id}.json", params: { subscribe: { status: 'approved' }, access_token: access_token } }

        it 'does not update subscribe' do
          request
          subscribe.reload

          expect(subscribe.status).to_not eq 'approved'
        end

        context 'in answer' do
          before { request }

          it 'returns status 403' do
            expect(response.status).to eq 403
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Access is forbidden')
          end
        end
      end

      context 'for valid params' do
        context 'for comment' do
          let(:request) { patch "/api/v1/subscribes/#{subscribe.id}.json", params: { subscribe: { comment: 'rejected' }, access_token: access_token } }

          it 'updates subscribe' do
            request
            subscribe.reload

            expect(subscribe.comment).to eq 'rejected'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id status comment character].each do |attr|
              it "and contains subscribe #{attr}" do
                expect(response.body).to have_json_path("subscribe/#{attr}")
              end
            end
          end
        end

        context 'for status' do
          let(:request) { patch "/api/v1/subscribes/#{subscribe.id}.json", params: { subscribe: { status: 'rejected' }, access_token: access_token } }

          it 'updates subscribe' do
            request
            subscribe.reload

            expect(subscribe.status).to eq 'rejected'
          end

          context 'in answer' do
            before { request }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id status comment character].each do |attr|
              it "and contains subscribe #{attr}" do
                expect(response.body).to have_json_path("subscribe/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers = {})
      patch '/api/v1/subscribes/999.json', params: { subscribe: { status: 'approved' } }, headers: headers
    end
  end
end
