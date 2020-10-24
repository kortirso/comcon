# frozen_string_literal: true

RSpec.describe 'Deliveries API' do
  describe 'POST#create' do
    let!(:notification) { create :notification }
    let!(:guild) { create :guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted deliveriable' do
        let(:request) { post '/api/v1/deliveries.json', params: { access_token: access_token, delivery: { deliveriable_id: 0, deliveriable_type: 'Guild', notification_id: notification.id } } }

        it 'does not create new character' do
          expect { request }.not_to change(Character, :count)
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
          let(:request) { post '/api/v1/deliveries.json', params: { access_token: access_token, delivery: { deliveriable_id: guild.id, deliveriable_type: 'Guild', notification_id: notification.id }, delivery_param: { params: { id: '', token: '' } } } }

          it 'calls CreateDeliveryWithParams' do
            expect(CreateDeliveryWithParams).to receive(:call).and_call_original

            request
          end

          it 'does not create new delivery' do
            expect { request }.not_to change(Delivery, :count)
          end

          it 'and does not create new delivery param' do
            expect { request }.not_to change(DeliveryParam, :count)
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
          let(:request) { post '/api/v1/deliveries.json', params: { access_token: access_token, delivery: { deliveriable_id: guild.id, deliveriable_type: 'Guild', notification_id: notification.id }, delivery_param: { params: { id: '123', token: '234' } } } }

          it 'calls CreateDeliveryWithParams' do
            expect(CreateDeliveryWithParams).to receive(:call).and_call_original

            request
          end

          it 'and creates new delivery' do
            expect { request }.to change { guild.deliveries.count }.by(1)
          end

          it 'and creates new delivery param' do
            expect { request }.to change(DeliveryParam, :count).by(1)
          end

          it 'calls CreateDublicateForGmUser' do
            expect(CreateDublicateForGmUser).to receive(:call).and_call_original

            request
          end

          context 'in answer' do
            before { request }

            it 'returns status 201' do
              expect(response.status).to eq 201
            end

            %w[id deliveriable].each do |attr|
              it "and contains delivery #{attr}" do
                expect(response.body).to have_json_path("delivery/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers={})
      post '/api/v1/deliveries.json', params: { delivery: { deliveriable_id: guild.id, deliveriable_type: 'Guild' } }, headers: headers
    end
  end
end
