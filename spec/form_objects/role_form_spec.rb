RSpec.describe RoleForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { RoleForm.new(name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new role' do
        expect { service.persist? }.to_not change(Role, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:role) { create :role }

      context 'for existed role' do
        let(:service) { RoleForm.new(name: { 'en' => role.name['en'], 'ru' => role.name['ru'] }) }

        it 'does not create new role' do
          expect { service.persist? }.to_not change(Role, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted role' do
        let(:service) { RoleForm.new(name: { 'en' => 'Tank', 'ru' => 'Танк' }) }

        it 'creates new role' do
          expect { service.persist? }.to change { Role.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
