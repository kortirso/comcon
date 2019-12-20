RSpec.describe WorldDryForm, type: :service do
  describe '.save' do
    context 'for invalid data' do
      let(:service) { described_class.new(id: nil, name: '', zone: '') }

      it 'does not create new world' do
        expect { service.save }.to_not change(World, :count)
      end

      it 'and returns false' do
        expect(service.save).to eq false
      end

      it 'and form contains errors' do
        service.save

        expect(service.errors.size.positive?).to eq true
      end
    end

    context 'for valid data' do
      let!(:world) { create :world }

      context 'for existed world' do
        let(:service) { described_class.new(id: nil, name: world.name, zone: world.zone) }

        it 'does not create new world' do
          expect { service.save }.to_not change(World, :count)
        end

        it 'and returns false' do
          expect(service.save).to eq false
        end

        it 'and form contains errors' do
          service.save

          expect(service.errors.size.positive?).to eq true
        end
      end

      context 'for unexisted world' do
        let(:service) { described_class.new(id: nil, name: 'Хроми', zone: 'RU') }

        it 'creates new world' do
          expect { service.save }.to change { World.count }.by(1)
        end

        it 'and returns true' do
          expect(service.save).to eq true
        end

        it 'and form contains created world' do
          service.save

          expect(service.world).to eq World.last
        end
      end
    end

    context 'for updating' do
      let!(:world1) { create :world }
      let!(:world2) { create :world }

      context 'for unexisted world' do
        let(:service) { described_class.new(id: 999, name: '1', zone: '2') }

        it 'returns false' do
          expect(service.save).to eq false
        end

        it 'and form contains errors' do
          service.save

          expect(service.errors.size.positive?).to eq true
        end
      end

      context 'for existed world' do
        context 'for invalid data' do
          let(:service) { described_class.new(id: world1.id, name: '', zone: '') }

          it 'does not update world' do
            service.save
            world1.reload

            expect(world1.name).to_not eq ''
            expect(world1.zone).to_not eq ''
          end

          it 'and form contains errors' do
            service.save

            expect(service.errors.size.positive?).to eq true
          end
        end

        context 'for existed data' do
          let(:service) { described_class.new(id: world1.id, name: world2.name, zone: world2.zone) }

          it 'does not update world' do
            service.save
            world1.reload

            expect(world1.name).to_not eq world2.name
          end

          it 'and form contains errors' do
            service.save

            expect(service.errors.size.positive?).to eq true
          end
        end

        context 'for valid data' do
          let(:service) { described_class.new(id: world1.id, name: 'Хроми', zone: 'RU') }

          it 'does not update world' do
            service.save
            world1.reload

            expect(world1.name).to eq 'Хроми'
            expect(world1.zone).to eq 'RU'
          end

          it 'and returns true' do
            expect(service.save).to eq true
          end

          it 'and form contains updated world' do
            service.save

            expect(service.world.id).to eq world1.id
          end
        end
      end
    end
  end
end
