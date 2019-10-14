RSpec.describe SubscribesController, type: :controller do
  describe 'POST#create' do
    let!(:event) { create :event }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user }

      context 'for invalid params' do
        let(:request) { post :create, params: { locale: 'en', subscribe: { event_id: nil } } }

        it 'does not create new subscribe' do
          expect { request }.to_not change(Subscribe, :count)
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)).to eq('result' => 'Failed')
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { locale: 'en', subscribe: { event_id: event.id, character_id: character.id } } }

        it 'creates new subscribe' do
          expect { request }.to change { character.subscribes.count }.by(1)
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)['user_characters']).to_not eq nil
          expect(JSON.parse(response.body)['characters']).to_not eq nil
        end
      end
    end

    def do_request
      post :create, params: { locale: 'en', subscribe: { event_id: event.id, character_id: nil } }
    end
  end

  describe 'POST#reject' do
    let!(:event) { create :event }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user }

      context 'for invalid params' do
        let(:request) { post :reject, params: { locale: 'en', subscribe: { event_id: nil } } }

        it 'does not create new subscribe' do
          expect { request }.to_not change(Subscribe, :count)
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)).to eq('result' => 'Failed')
        end
      end

      context 'for valid params' do
        let(:request) { post :reject, params: { locale: 'en', subscribe: { event_id: event.id, character_id: character.id } } }

        it 'creates new subscribe' do
          expect { request }.to change { character.subscribes.count }.by(1)
        end

        it 'and its signed is false' do
          request

          expect(Subscribe.last.signed).to eq false
        end

        it 'and returns json response' do
          request

          expect(JSON.parse(response.body)['user_characters']).to_not eq nil
          expect(JSON.parse(response.body)['characters']).to_not eq nil
        end
      end
    end

    def do_request
      post :reject, params: { locale: 'en', subscribe: { event_id: event.id, character_id: nil } }
    end
  end
end
