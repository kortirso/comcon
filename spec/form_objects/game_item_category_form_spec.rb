# frozen_string_literal: true

RSpec.describe GameItemCategoryForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(uid: '', name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new object' do
        expect { service.persist? }.not_to change(GameItemCategory, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let(:service) { described_class.new(uid: 7, name: { 'en' => 'Trade Goods', 'ru' => 'Хозяйственные товары' }) }

      it 'creates new object' do
        expect { service.persist? }.to change(GameItemCategory, :count).by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end
  end
end
