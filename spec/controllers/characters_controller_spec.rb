RSpec.describe CharactersController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      it 'renders index template' do
        get :index, params: { locale: 'en' }

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      it 'renders new template' do
        get :new, params: { locale: 'en' }

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new, params: { locale: 'en' }
    end
  end

  describe 'POST#create' do
    let!(:race) { create :race, :human }
    let!(:character_class) { create :character_class, :warrior }
    let!(:world) { create :world }

    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for invalid params' do
        let(:request) { post :create, params: { locale: 'en', character: { name: '' } } }

        it 'does not create new character' do
          expect { request }.to_not change(Character, :count)
        end

        it 'and renders new template' do
          request

          expect(response).to render_template :new
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { locale: 'en', character: { name: '1', level: 60, world_id: world.id, race_id: race.id, character_class_id: character_class.id } } }

        it 'creates new character' do
          expect { request }.to change { Character.count }.by(1)
        end

        it 'and redirects to characters path' do
          request

          expect(response).to redirect_to characters_en_path
        end
      end
    end

    def do_request
      post :create, params: { locale: 'en', character: { name: '1', level: 60, world_id: world.id, race_id: race.id, character_class_id: character_class.id } }
    end
  end

  describe 'GET#edit' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted character' do
        it 'renders error template' do
          get :edit, params: { locale: 'en', id: 999 }

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed character' do
        let!(:character) { create :character, :human_warrior, user: @current_user }

        it 'renders edit template' do
          get :edit, params: { locale: 'en', id: character.id }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { locale: 'en', id: 999 }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted character' do
        let(:request) { patch :update, params: { locale: 'en', id: 999, character: { name: '' } } }

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed character' do
        let!(:character) { create :character, :human_warrior, user: @current_user }

        context 'for invalid params' do
          let(:request) { patch :update, params: { locale: 'en', id: character.id, character: { name: '' } } }

          it 'does not update new character' do
            request
            character.reload

            expect(character.name).to_not eq ''
          end

          it 'and renders edit template' do
            request

            expect(response).to render_template :edit
          end
        end

        context 'for valid params' do
          let(:request) { patch :update, params: { locale: 'en', id: character.id, character: { name: '1', level: 60, race_id: character.race_id, world_id: character.world_id, character_class_id: character.character_class_id } } }

          it 'updates new character' do
            request
            character.reload

            expect(character.name).to eq '1'
          end

          it 'and redirects to characters path' do
            request

            expect(response).to redirect_to characters_en_path
          end
        end
      end
    end

    def do_request
      patch :update, params: { locale: 'en', id: 999, character: { name: '1' } }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'User Auth'

    context 'for logged user' do
      sign_in_user

      context 'for unexisted character' do
        let(:request) { delete :destroy, params: { locale: 'en', id: 999 } }

        it 'does not delete any character' do
          expect { request }.to_not change(Character, :count)
        end

        it 'and renders error template' do
          request

          expect(response).to render_template 'shared/error'
        end
      end

      context 'for existed character' do
        let!(:character) { create :character, :human_warrior, user: @current_user }
        let(:request) { delete :destroy, params: { locale: 'en', id: character.id } }

        it 'deletes character' do
          expect { request }.to change { Character.count }.by(-1)
        end

        it 'and redirects to characters path' do
          request

          expect(response).to redirect_to characters_en_path
        end
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en', id: 999 }
    end
  end
end
