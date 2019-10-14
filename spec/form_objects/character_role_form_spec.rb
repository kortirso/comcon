RSpec.describe CharacterRoleForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { CharacterRoleForm.new(character: nil) }

      it 'does not create new character role' do
        expect { service.persist? }.to_not change(CharacterRole, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:character) { create :character }
      let!(:role) { create :role }
      let!(:character_role) { create :character_role }

      context 'for existed character role' do
        let(:service) { CharacterRoleForm.new(character: character_role.character, role: character_role.role) }

        it 'does not create new character role' do
          expect { service.persist? }.to_not change(CharacterRole, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted character' do
        let(:service) { CharacterRoleForm.new(character: character, role: role) }

        it 'creates new character role' do
          expect { service.persist? }.to change { character.character_roles.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:character) { create :character }
      let!(:character_role1) { create :character_role, character: character }
      let!(:character_role2) { create :character_role }

      context 'for unexisted character role' do
        let(:service) { CharacterRoleForm.new(id: 999, main: true) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed character role' do
        context 'for invalid data' do
          let(:service) { CharacterRoleForm.new(character_role1.attributes.merge(character: nil, role: nil, main: true)) }

          it 'does not update character role' do
            service.persist?
            character_role1.reload

            expect(character_role1.main).to_not eq true
          end
        end

        context 'for existed data' do
          let(:service) { CharacterRoleForm.new(character_role1.attributes.merge(character: character_role2.character, role: character_role2.role, main: true)) }

          it 'does not update character role' do
            service.persist?
            character_role1.reload

            expect(character_role1.main).to_not eq true
          end
        end

        context 'for valid data' do
          let(:service) { CharacterRoleForm.new(character_role1.attributes.merge(character: character_role1.character, role: character_role1.role, main: true)) }

          it 'updates character role' do
            service.persist?
            character_role1.reload

            expect(character_role1.main).to eq true
          end
        end
      end
    end
  end
end
