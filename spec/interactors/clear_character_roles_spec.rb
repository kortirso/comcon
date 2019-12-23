describe ClearCharacterRoles do
  let!(:character) { create :character }
  let!(:bank_request) { create :bank_request, character: character }
  let!(:guild_invite) { create :guild_invite, character: character }
  let!(:guild_role) { create :guild_role, character: character }
  let!(:static_invite) { create :static_invite, character: character }
  let!(:static_member) { create :static_member, character: character }
  let!(:subscribe) { create :subscribe, character: character }

  describe '.call' do
    let(:interactor) { described_class.call(character_id: character.id) }

    it 'succeeds' do
      expect(interactor).to be_a_success
    end

    it 'and deletes bank requests' do
      expect { interactor }.to change { BankRequest.count }.by(-1)
    end

    it 'and deletes guild invites' do
      expect { interactor }.to change { GuildInvite.count }.by(-1)
    end

    it 'and deletes guild role' do
      expect { interactor }.to change { GuildRole.count }.by(-1)
    end

    it 'and deletes static invites' do
      expect { interactor }.to change { StaticInvite.count }.by(-1)
    end

    it 'and deletes static members' do
      expect { interactor }.to change { StaticMember.count }.by(-1)
    end

    it 'and deletes subscribe' do
      expect { interactor }.to change { Subscribe.count }.by(-1)
    end
  end
end
