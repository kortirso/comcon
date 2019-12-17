RSpec.describe 'BankRequests API' do
  describe 'GET#index' do
    let!(:user) { create :user }
    let!(:guild) { create :guild }
    let!(:character) { create :character, user: user, guild: guild }
    let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'ba' }
    let!(:bank) { create :bank, guild: guild }
    let!(:game_item) { create :game_item }
    let!(:bank_cell) { create :bank_cell, bank: bank, game_item: game_item, amount: 10 }
    let!(:bank_request1) { create :bank_request, bank: bank, character: character, game_item: game_item, requested_amount: 1 }
    let!(:bank_request2) { create :bank_request, game_item: game_item, requested_amount: 1 }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted guild' do
        before { get '/api/v1/bank_requests.json', params: { access_token: access_token, guild_id: 'unexisted' } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns errors' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed guild' do
        before { get '/api/v1/bank_requests.json', params: { access_token: access_token, guild_id: guild.id } }

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        it 'and returns only guild bank requests' do
          result = JSON.parse(response.body)['bank_requests']

          expect(result.size).to eq 1
          expect(result[0]['id']).to eq bank_request1.id
        end

        %w[id character_name bank_name game_item_name requested_amount].each do |attr|
          it "and contains bank request #{attr}" do
            expect(response.body).to have_json_path("bank_requests/0/#{attr}")
          end
        end
      end
    end

    def do_request(headers = {})
      get '/api/v1/bank_requests.json', params: { guild_id: guild.id }, headers: headers
    end
  end

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

        it 'calls CreateBankRequestJob' do
          expect(CreateBankRequestJob).to receive(:perform_now).and_call_original

          request
        end

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

  describe 'POST#decline' do
    let!(:user) { create :user }
    let!(:guild) { create :guild }
    let!(:character) { create :character, user: user, guild: guild }
    let!(:bank) { create :bank, guild: guild }
    let!(:bank_request) { create :bank_request, bank: bank }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted bank request' do
        let(:request) { post '/api/v1/bank_requests/unexisted/decline.json', params: { access_token: access_token } }

        it 'does not call decline' do
          expect_any_instance_of(BankRequest).to_not receive(:decline).and_call_original

          request
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

      context 'for existed bank request' do
        let(:request) { post "/api/v1/bank_requests/#{bank_request.id}/decline.json", params: { access_token: access_token } }

        it 'calls decline' do
          expect_any_instance_of(BankRequest).to receive(:decline).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns result' do
            expect(JSON.parse(response.body)).to eq('result' => 'Bank request is declined')
          end
        end
      end
    end

    def do_request(headers = {})
      post "/api/v1/bank_requests/#{bank_request.id}/decline.json", headers: headers
    end
  end

  describe 'POST#approve' do
    let!(:user) { create :user }
    let!(:guild) { create :guild }
    let!(:character) { create :character, user: user, guild: guild }
    let!(:bank) { create :bank, guild: guild }
    let!(:game_item) { create :game_item }
    let!(:bank_cell) { create :bank_cell, bank: bank, game_item: game_item, amount: 10 }
    let!(:bank_request) { create :bank_request, bank: bank, game_item: game_item, requested_amount: 1 }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted bank request' do
        let(:request) { post '/api/v1/bank_requests/unexisted/approve.json', params: { access_token: access_token } }

        it 'does not call ApproveBankRequest' do
          expect(ApproveBankRequest).to_not receive(:call).and_call_original

          request
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

      context 'for existed bank request' do
        let(:request) { post "/api/v1/bank_requests/#{bank_request.id}/approve.json", params: { access_token: access_token } }

        it 'calls ApproveBankRequest' do
          expect(ApproveBankRequest).to receive(:call).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          %w[id amount item_uid game_item].each do |attr|
            it "and contains bank cell #{attr}" do
              expect(response.body).to have_json_path("bank_cell/#{attr}")
            end
          end
        end
      end
    end

    def do_request(headers = {})
      post "/api/v1/bank_requests/#{bank_request.id}/approve.json", headers: headers
    end
  end

  describe 'DELETE#destroy' do
    let!(:user) { create :user }
    let!(:guild) { create :guild }
    let!(:character) { create :character, user: user, guild: guild }
    let!(:bank) { create :bank, guild: guild }
    let!(:game_item) { create :game_item }
    let!(:bank_cell) { create :bank_cell, bank: bank, game_item: game_item, amount: 10 }
    let!(:bank_request) { create :bank_request, bank: bank, game_item: game_item, requested_amount: 1, character: character }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted bank request' do
        before { delete '/api/v1/bank_requests/unexisted.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed bank request' do
        let(:request) { delete "/api/v1/bank_requests/#{bank_request.id}.json", params: { access_token: access_token } }

        it 'deletes bank request' do
          expect { request }.to change { BankRequest.count }.by(-1)
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Bank request is destroyed')
          end
        end
      end
    end

    def do_request(headers = {})
      delete "/api/v1/bank_requests/#{bank_request.id}.json", headers: headers
    end
  end
end
