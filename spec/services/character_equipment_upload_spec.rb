RSpec.describe CharacterEquipmentUpload, type: :service do
  describe '.call' do
    let!(:character) { create :character }
    let(:request) { described_class.call(character_id: character.id, value: '8176:;12039:;10774:;49:;13110:16;5609:;9624:;2033:;9857:;10777:;10710:;2933:;0:0;0:0;4114:;10823:;6829:;3108:;23192:;') }

    it 'creates character equipment' do
      expect { request }.to change { character.equipment.count }.by(17)
    end

    it 'and returns true' do
      expect(request).to eq true
    end
  end
end
