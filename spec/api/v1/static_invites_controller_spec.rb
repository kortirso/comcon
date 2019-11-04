RSpec.describe 'StaticInvites API' do
  describe 'POST#create' do
    it_behaves_like 'API auth without token'
    it_behaves_like 'API auth with invalid token'

    context 'for logged user' do
      let!(:user) { create :user }
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild, user: user }
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let!(:guild_static) { create :static, staticable: guild, fraction: character.race.fraction, world: character.world }
      let!(:character_static) { create :static, staticable: character, fraction: character.race.fraction, world: character.world }
      let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }

      context 'for unexisted static' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: 'unexisted', character_id: character.id } } }

        it 'does not create new static invite' do
          expect { request }.to_not change(StaticInvite, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 400' do
            expect(response.status).to eq 400
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end
      end

      context 'for unexisted character' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: guild_static.id, character_id: 'unexisted' } } }

        it 'does not create new static invite' do
          expect { request }.to_not change(StaticInvite, :count)
        end

        context 'in answer' do
          before { request }

          it 'returns status 400' do
            expect(response.status).to eq 400
          end

          it 'and returns error message' do
            expect(JSON.parse(response.body)).to eq('error' => 'Object is not found')
          end
        end
      end

      context 'for guild static' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: guild_static.id, character_id: character.id } } }

        context 'for existed static member' do
          let!(:static_member) { create :static_member, static: guild_static, character: character }

          it 'does not create new static member' do
            expect { request }.to_not change(StaticMember, :count)
          end

          it 'does not create new static invite' do
            expect { request }.to_not change(StaticInvite, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 409' do
              expect(response.status).to eq 409
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)['errors']).to_not eq nil
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
            expect { request }.to_not change(StaticInvite, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 201' do
              expect(response.status).to eq 201
            end

            %w[id name level character_class race guild world].each do |attr|
              it "and contains character #{attr}" do
                expect(response.body).to have_json_path("character/#{attr}")
              end
            end
          end
        end
      end

      context 'for character static' do
        let(:request) { post '/api/v1/static_invites.json', params: { access_token: access_token, static_invite: { static_id: character_static.id, character_id: character.id } } }

        context 'for existed static invite' do
          let!(:static_member) { create :static_member, static: character_static, character: character }

          it 'does not create new static member' do
            expect { request }.to_not change(StaticMember, :count)
          end

          it 'does not create new static invite' do
            expect { request }.to_not change(StaticInvite, :count)
          end

          context 'in answer' do
            before { request }

            it 'returns status 409' do
              expect(response.status).to eq 409
            end

            it 'and returns error message' do
              expect(JSON.parse(response.body)['errors']).to_not eq nil
            end
          end
        end

        context 'for valid invite params' do
          it 'does not create new static member' do
            expect { request }.to_not change(character_static.static_members, :count)
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

    def do_request(headers = {})
      post '/api/v1/static_invites.json', params: { static: { static_id: nil } }, headers: headers
    end
  end
end
