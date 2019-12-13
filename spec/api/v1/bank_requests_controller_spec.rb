RSpec.describe 'BankRequests API' do
  describe 'POST#create' do
    let!(:user) { create :user }
    let!(:guild) { create :guild }
    let!(:character) { create :character, user: user, guild: guild }
    let!(:bank) { create :bank, guild: guild }
    let!(:game_item) { create :game_item }
    let!(:bank_cell) { create :bank_cell, bank: bank, game_item: game_item, amount: 10 }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted bank' do
        let(:request) { post '/api/v1/bank_requests.json', params: { access_token: access_token, bank_request: { bank_id: 'unexisted', requested_amount: 1 } } }

        it 'does not create new bank request' do
          expect { request }.to_not change(BankRequest, :count)
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

      context 'for unexisted character' do
        let(:request) { post '/api/v1/bank_requests.json', params: { access_token: access_token, bank_request: { bank_id: bank.id, character_id: 'unexisted', requested_amount: 1 } } }

        it 'does not create new bank request' do
          expect { request }.to_not change(BankRequest, :count)
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

      context 'for unexisted game item' do
        let(:request) { post '/api/v1/bank_requests.json', params: { access_token: access_token, bank_request: { bank_id: bank.id, character_id: character.id, game_item_id: 'unexisted', requested_amount: 1 } } }

        it 'does not create new bank request' do
          expect { request }.to_not change(BankRequest, :count)
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

      context 'for invalid params' do
        let(:request) { post '/api/v1/bank_requests.json', params: { access_token: access_token, bank_request: { bank_id: bank.id, character_id: character.id, game_item_id: game_item.id, requested_amount: 20 } } }

        it 'does not create new bank request' do
          expect { request }.to_not change(BankRequest, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 409' do
            expect(response.status).to eq 409
          end

          it 'and returns errors' do
            expect(JSON.parse(response.body)['errors']).to_not eq nil
          end
        end
      end

      context 'for valid params' do
        let(:request) { post '/api/v1/bank_requests.json', params: { access_token: access_token, bank_request: { bank_id: bank.id, character_id: character.id, game_item_id: game_item.id, requested_amount: 5 } } }

        it 'and creates new bank request' do
          expect { request }.to change { bank.bank_requests.count }.by(1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 201' do
            expect(response.status).to eq 201
          end

          %w[id character_name bank_name game_item_name requested_amount].each do |attr|
            it "and contains bank request #{attr}" do
              expect(response.body).to have_json_path("bank_request/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post '/api/v1/bank_requests.json', params: { bank_request: { requested_amount: 1 } }, headers: headers
    end
  end
end
