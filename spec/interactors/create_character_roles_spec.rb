describe CreateCharacterRoles do
  let!(:character) { create :character }
  let!(:role) { create :role }

  describe '.call' do
    context 'for unexisted character role' do
      let(:interactor) { CreateCharacterRoles.call(character_id: character.id, character_role_params: { 'roles' => { role.id.to_s => '1' } }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates character role' do
        expect { interactor }.to change { character.character_roles.count }.by(1)
      end
    end

    context 'for unexisted character role, with main' do
      let(:interactor) { CreateCharacterRoles.call(character_id: character.id, character_role_params: { 'main_role_id' => role.id.to_s, 'roles' => { role.id.to_s => '1' } }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates character role' do
        expect { interactor }.to change { character.character_roles.count }.by(1)
      end

      it 'and its main role' do
        interactor

        expect(CharacterRole.last.main).to eq true
      end
    end

    context 'for existed character role' do
      let!(:character_role) { create :character_role, character: character, role: role }
      let(:interactor) { CreateCharacterRoles.call(character_id: character.id, character_role_params: { 'roles' => { role.id.to_s => '0' } }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and deletes character role' do
        expect { interactor }.to change { CharacterRole.count }.by(-1)
      end
    end
  end
end
