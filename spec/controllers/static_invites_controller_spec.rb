# frozen_string_literal: true

RSpec.describe StaticInvitesController, type: :controller do
  describe 'GET#find' do
    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user

      context 'without user characters' do
        it 'renders find template' do
          get :find, params: { locale: 'en' }

          expect(response).to render_template :find
        end
      end

      context 'with user characters' do
        let!(:character) { create :character, user: @current_user }

        it 'renders find template' do
          get :find, params: { locale: 'en' }

          expect(response).to render_template :find
        end
      end
    end

    def do_request
      get :find, params: { locale: 'en' }
    end
  end

  describe 'GET#approve' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user, guild: guild }
      let!(:other_character) { create :character, guild: guild, world: character.world, race: character.race }
      let!(:static) { create :static, staticable: guild, world: character.world, fraction: character.race.fraction }
      let!(:group_role) { create :group_role, groupable: static }

      context 'for unexisted static invite' do
        it 'renders error page' do
          get :approve, params: { locale: 'en', id: 'unexisted' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed static invite' do
        context 'for invalid access' do
          let!(:static_invite) { create :static_invite, static: static, character: other_character }
          let(:request) { get :approve, params: { locale: 'en', id: static_invite.id } }

          it 'calls ApproveStaticInvite' do
            expect(ApproveStaticInvite).not_to receive(:call).and_call_original

            request
          end

          it 'and does not create new static member' do
            expect { request }.not_to change(StaticMember, :count)
          end

          it 'and renders error page' do
            request

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for valid access' do
          let!(:static_invite) { create :static_invite, static: static, character: character }
          let(:request) { get :approve, params: { locale: 'en', id: static_invite.id } }

          it 'calls ApproveStaticInvite' do
            expect(ApproveStaticInvite).to receive(:call).and_call_original

            request
          end

          it 'and creates new static member' do
            expect { request }.to change(StaticMember, :count).by(1)
          end

          it 'and deletes static invite' do
            expect { request }.to change(StaticInvite, :count).by(-1)
          end

          it 'and redirects to statics path' do
            request

            expect(response).to redirect_to statics_en_path
          end
        end
      end
    end

    def do_request
      get :approve, params: { locale: 'en', id: 'unexisted' }
    end
  end

  describe 'GET#decline' do
    let!(:guild) { create :guild }

    it_behaves_like 'User Auth'
    it_behaves_like 'Unconfirmed User Auth'

    context 'for logged user' do
      sign_in_user
      let!(:character) { create :character, user: @current_user, guild: guild }
      let!(:other_character) { create :character, guild: guild, world: character.world, race: character.race }
      let!(:static) { create :static, staticable: guild, world: character.world, fraction: character.race.fraction }

      context 'for unexisted static invite' do
        it 'renders error page' do
          get :decline, params: { locale: 'en', id: 'unexisted' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed static invite' do
        context 'for invalid access' do
          let!(:static_invite) { create :static_invite, static: static, character: other_character }
          let(:request) { get :decline, params: { locale: 'en', id: static_invite.id } }

          it 'calls UpdateStaticInvite' do
            expect(UpdateStaticInvite).not_to receive(:call).and_call_original

            request
          end

          it 'and does not update static invite' do
            request
            static_invite.reload

            expect(static_invite.status_send?).to eq true
          end

          it 'and renders error page' do
            request

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for valid access' do
          let!(:static_invite) { create :static_invite, static: static, character: character }
          let(:request) { get :decline, params: { locale: 'en', id: static_invite.id } }

          it 'calls UpdateStaticInvite' do
            expect(UpdateStaticInvite).to receive(:call).and_call_original

            request
          end

          it 'and updates static invite' do
            request
            static_invite.reload

            expect(static_invite.status_declined?).to eq true
          end

          it 'and redirects to statics path' do
            request

            expect(response).to redirect_to statics_en_path
          end
        end
      end
    end

    def do_request
      get :decline, params: { locale: 'en', id: 'unexisted' }
    end
  end
end
