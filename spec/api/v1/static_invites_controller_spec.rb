# frozen_string_literal: true

RSpec.describe 'StaticInvites API' do
  describe 'GET#index' do
    let!(:guild) { create :guild }
    let!(:static) { create :static, staticable: guild }

    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'with valid user token in params' do
      let!(:user) { create :user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'without static or character param' do
        before { get '/api/v1/static_invites.json', params: { access_token: access_token } }

        it 'returns status 400' do
          expect(response.status).to eq 400
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Static ID or Character ID must be presented')
        end
      end

      context 'with static param' do
        context 'for unexisted static' do
          before { get '/api/v1/static_invites.json', params: { access_token: access_token, static_id: 'unexisted' } }

          it 'returns status 404' do
            expect(response.status).to eq 404
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed static' do
          let!(:character) { create :character, user: user }
          let!(:static) { create :static, staticable: character }
          let!(:static_invite) { create :static_invite, static: static }

          before { get '/api/v1/static_invites.json', params: { access_token: access_token, static_id: static.id } }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          %w[id static_name character from_static status].each do |attr|
            it "and contains static_invite #{attr}" do
              expect(response.body).to have_json_path("static_invites/0/#{attr}")
            end
          end
        end
      end

      context 'with character param' do
        context 'for unexisted character' do
          before { get '/api/v1/static_invites.json', params: { access_token: access_token, character_id: 'unexisted' } }

          it 'returns status 404' do
            expect(response.status).to eq 404
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end

        context 'for existed character' do
          context 'for not user character' do
            let!(:character) { create :character }

            before { get '/api/v1/static_invites.json', params: { access_token: access_token, character_id: character.id } }

            it 'returns status 404' do
              expect(response.status).to eq 404
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
            end
          end

          context 'for valid character' do
            let!(:character) { create :character, user: user }
            let!(:static_invite) { create :static_invite, static: static, character: character, from_static: true }

            before { get '/api/v1/static_invites.json', params: { access_token: access_token, character_id: character.id } }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end

            %w[id static_name character from_static status].each do |attr|
              it "and contains static_invite #{attr}" do
                expect(response.body).to have_json_path("static_invites/0/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers={})
      get '/api/v1/static_invites.json', params: { static_id: static.id }, headers: headers
    end
  end

  describe 'POST#create' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let!(:guild_static) { create :static, staticable: guild, fraction: character.race.fraction, world: character.world }
      let!(:group_role) { create :group_role, groupable: guild_static }
      let!(:character_static) { create :static, staticable: character, fraction: character.race.fraction, world: character.world }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted static' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: 'unexisted', character_id: character.id } } }

        it 'does not create new static invite' do
          expect { request }.not_to change(StaticInvite, :count)
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

      context 'for unexisted character' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: guild_static.id, character_id: 'unexisted' } } }

        it 'does not create new static invite' do
          expect { request }.not_to change(StaticInvite, :count)
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

      context 'from static' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: guild_static.id, character_id: character.id, from_static: 'true' } } }

        context 'for existed static member' do
          let!(:static_member) { create :static_member, static: guild_static, character: character }

          it 'does not create new static member' do
            expect { request }.not_to change(StaticMember, :count)
          end

          it 'does not create new static invite' do
            expect { request }.not_to change(StaticInvite, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 409' do
              expect(response.status).to eq 409
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)).to eq('error' => 'Static member already exists')
            end
          end
        end

        context 'for valid invite params' do
          it 'calls CreateStaticMember' do
            expect(CreateStaticMember).to receive(:call).and_call_original

            request
          end

          it 'and creates new static member' do
            expect { request }.to change { guild_static.static_members.count }.by(1)
          end

          it 'and does not create new static invite' do
            expect { request }.not_to change(StaticInvite, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 201' do
              expect(response.status).to eq 201
            end

            %w[id static_id character].each do |attr|
              it "and contains member #{attr}" do
                expect(response.body).to have_json_path("member/#{attr}")
              end
            end
          end
        end
      end

      context 'from character' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: character_static.id, character_id: character.id, from_static: 'false' } } }

        context 'for existed static invite' do
          let!(:static_member) { create :static_member, static: character_static, character: character }

          it 'does not create new static member' do
            expect { request }.not_to change(StaticMember, :count)
          end

          it 'does not create new static invite' do
            expect { request }.not_to change(StaticInvite, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 409' do
              expect(response.status).to eq 409
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)).to eq('error' => 'Static member already exists')
            end
          end
        end

        context 'for valid invite params' do
          it 'does not create new static member' do
            expect { request }.not_to change(character_static.static_members, :count)
          end

          it 'and creates new static invite' do
            expect { request }.to change { character_static.static_invites.count }.by(1)
          end

          context 'in answer' do
            before { request }

            it 'returns status 201' do
              expect(response.status).to eq 201
            end

            %w[id static_id status character].each do |attr|
              it "and contains invite #{attr}" do
                expect(response.body).to have_json_path("invite/#{attr}")
              end
            end
          end
        end
      end
    end

    def do_request(headers={})
      post '/api/v1/static_invites.json', params: { static: { static_id: nil } }, headers: headers
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted static invite' do
        before { delete '/api/v1/static_invites/unexisted.json', params: { access_token: access_token } }

        it 'returns status 404' do
          expect(response.status).to eq 404
        end

        it 'and returns error message' do
          expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
        end
      end

      context 'for existed static invite' do
        let!(:static) { create :static, staticable: guild, world: character.world, fraction: character.race.fraction }
        let!(:static_invite) { create :static_invite, static: static, character: character }

        context 'for unavailable static invite' do
          before { delete "/api/v1/static_invites/#{static_invite.id}.json", params: { access_token: access_token } }

          it 'returns status 403' do
            expect(response.status).to eq 403
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Access is forbidden')
          end
        end

        context 'for available static invite' do
          let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }

          before { delete "/api/v1/static_invites/#{static_invite.id}.json", params: { access_token: access_token } }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns result message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Static invite is destroyed')
          end
        end
      end
    end

    def do_request(headers={})
      delete '/api/v1/static_invites/unexisted.json', headers: headers
    end
  end

  describe 'POST#approve' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let!(:guild_static) { create :static, staticable: guild, fraction: character.race.fraction, world: character.world }
      let!(:group_role) { create :group_role, groupable: guild_static }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted static invite' do
        let(:request) { post '/api/v1/static_invites/unexisted/approve.json', params: { access_token: access_token } }

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

      context 'for existed static invite' do
        let!(:static_invite) { create :static_invite, static: guild_static, from_static: false }
        let(:request) { post "/api/v1/static_invites/#{static_invite.id}/approve.json", params: { access_token: access_token } }

        it 'calls ApproveStaticInvite' do
          expect(ApproveStaticInvite).to receive(:call).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Character is added to the static')
          end
        end
      end
    end

    def do_request(headers={})
      post '/api/v1/static_invites/unexisted/approve.json', headers: headers
    end
  end

  describe 'POST#decline' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'
    it_behaves_like 'API auth unconfirmed'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let!(:guild_static) { create :static, staticable: guild, fraction: character.race.fraction, world: character.world }
      let!(:group_role) { create :group_role, groupable: guild_static }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted static invite' do
        let(:request) { post '/api/v1/static_invites/unexisted/decline.json', params: { access_token: access_token } }

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

      context 'for existed static invite' do
        let!(:static_invite) { create :static_invite, static: guild_static, from_static: false }
        let(:request) { post "/api/v1/static_invites/#{static_invite.id}/decline.json", params: { access_token: access_token } }

        it 'calls UpdateStaticInvite' do
          expect(UpdateStaticInvite).to receive(:call).and_call_original

          request
        end

        context 'in answer' do
          before { request }

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('result' => 'Static invite is declined')
          end
        end
      end
    end

    def do_request(headers={})
      post '/api/v1/static_invites/unexisted/decline.json', headers: headers
    end
  end
end
