RSpec.describe CharacterClassForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { CharacterClassForm.new(name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new character_class' do
        expect { service.persist? }.to_not change(CharacterClass, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:character_class) { create :character_class, :warrior }

      context 'for existed character_class' do
        let(:service) { CharacterClassForm.new(name: { 'en' => character_class.name['en'], 'ru' => character_class.name['ru'] }) }

        it 'does not create new character_class' do
          expect { service.persist? }.to_not change(CharacterClass, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted character_class' do
        let(:service) { CharacterClassForm.new(name: { 'en' => 'Mage', 'ru' => 'Маг' }) }

        it 'creates new character_class' do
          expect { service.persist? }.to change { CharacterClass.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
