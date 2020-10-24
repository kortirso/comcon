# frozen_string_literal: true

RSpec.describe World, type: :model do
  it { is_expected.to have_many(:characters).dependent(:destroy) }
  it { is_expected.to have_many(:guilds).dependent(:destroy) }
  it { is_expected.to have_many(:events).dependent(:destroy) }
  it { is_expected.to have_many(:statics).dependent(:destroy) }
  it { is_expected.to have_many(:world_fractions).dependent(:destroy) }
  it { is_expected.to have_one(:world_stat).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    world = build :world

    expect(world).to be_valid
  end

  describe 'methods' do
    describe '.full_name' do
      let!(:world) { create :world }

      it 'returns full name for world' do
        expect(world.full_name).to eq "#{world.name} (#{world.zone})"
      end
    end

    describe '.locale' do
      context 'for ru zone' do
        let!(:world) { create :world, zone: 'RU' }

        it 'returns ru' do
          expect(world.locale).to eq 'ru'
        end
      end

      context 'for en zone' do
        let!(:world) { create :world, zone: 'EN' }

        it 'returns en' do
          expect(world.locale).to eq 'en'
        end
      end

      context 'for other zone' do
        let!(:world) { create :world, zone: 'DA' }

        it 'returns en' do
          expect(world.locale).to eq 'en'
        end
      end
    end
  end
end
