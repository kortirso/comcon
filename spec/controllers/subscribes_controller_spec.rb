RSpec.describe SubscribesController, type: :controller do
  describe 'POST#create' do
    let!(:event) { create :event }

    it_behaves_like 'User Auth JSON'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user }

      context 'for invalid params' do
        let(:request) { post :create, params: { subscribe: { event_id: nil }, format: :json } }

        it 'does not create new subscribe' do
          expect { request }.to_not change(Subscribe, :count)
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { subscribe: { event_id: event.id, character_id: character.id, status: 'signed' }, format: :json } }

        it 'creates new subscribe' do
          expect { request }.to change { character.subscribes.count }.by(1)
        end

        it 'and its status is signed' do
          request

          expect(Subscribe.last.status).to eq 'signed'
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)['user_characters']).to_not eq nil
          expect(JSON.parse(response.body)['characters']).to_not eq nil
        end
      end
    end

    def do_request
      post :create, params: { subscribe: { event_id: event.id, character_id: nil }, format: :json }
    end
  end

  describe 'PATCH#update' do
    let!(:event) { create :event }

    it_behaves_like 'User Auth JSON'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user }
      let!(:subscribe) { create :subscribe, event: event, character: character, status: 'signed' }

      context 'for unexisted subscribe' do
        let(:request) { patch :update, params: { id: 999, subscribe: { status: 'approved' }, format: :json } }

        it 'returns json response' do
          request

          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for invalid params' do
        let(:request) { patch :update, params: { id: subscribe.id, subscribe: { status: 'approved' }, format: :json } }

        it 'does not update subscribe' do
          request
          subscribe.reload

          expect(subscribe.status).to_not eq 'approved'
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)).to eq('error' => 'Forbidden')
        end
      end

      context 'for valid params' do
        let(:request) { patch :update, params: { id: subscribe.id, subscribe: { status: 'rejected' }, format: :json } }

        it 'updates subscribe' do
          request
          subscribe.reload

          expect(subscribe.status).to eq 'rejected'
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)['user_characters']).to_not eq nil
          expect(JSON.parse(response.body)['characters']).to_not eq nil
        end
      end
    end

    def do_request
      patch :update, params: { id: 999, subscribe: { status: 'approved' }, format: :json }
    end
  end
end
