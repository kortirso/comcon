# frozen_string_literal: true

RSpec.describe Characters::Equipment::UploadService, type: :service do
  subject(:service_call) {
    described_class.call(
      character:   character,
      input_value: '8176:;12039:;10774:;49:;13110:16;5609:;9624:;2033:;9857:;10777:;10710:;2933:;0:0;0:0;4114:;10823:;6829:;3108:;23192:;'
    )
  }

  describe '.call' do
    let!(:character) { create :character }

    it 'creates character equipment' do
      expect { service_call }.to change { character.equipment.count }.by(17)
    end

    it 'and returns true' do
      service_object = service_call

      expect(service_object.success?).to eq true
    end
  end
end
