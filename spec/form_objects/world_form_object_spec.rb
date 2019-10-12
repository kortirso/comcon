RSpec.describe WorldForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { WorldForm.new(name: '', zone: '') }

      it 'does not create new world' do
        expect { service.persist? }.to_not change(World, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:world) { create :world }

      context 'for existed world' do
        let(:service) { WorldForm.new(name: world.name, zone: world.zone) }

        it 'does not create new world' do
          expect { service.persist? }.to_not change(World, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted world' do
        let(:service) { WorldForm.new(name: 'Хроми', zone: 'RU') }

        it 'creates new world' do
          expect { service.persist? }.to change { World.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:world1) { create :world }
      let!(:world2) { create :world }

      context 'for existed world' do
        let(:service) { WorldForm.new(id: 999, name: '1', zone: '2') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed world' do
        context 'for invalid data' do
          let(:service) { WorldForm.new(id: world1.id, name: '', zone: '') }

          it 'does not update world' do
            service.persist?
            world1.reload

            expect(world1.name).to_not eq ''
            expect(world1.zone).to_not eq ''
          end
        end

        context 'for existed data' do
          let(:service) { WorldForm.new(id: world1.id, name: world2.name, zone: world2.zone) }

          it 'does not update world' do
            service.persist?
            world1.reload

            expect(world1.name).to_not eq world2.name
          end
        end

        context 'for valid data' do
          let(:service) { WorldForm.new(id: world1.id, name: 'Хроми', zone: 'RU') }

          it 'does not update world' do
            service.persist?
            world1.reload

            expect(world1.name).to eq 'Хроми'
            expect(world1.zone).to eq 'RU'
          end
        end
      end
    end
  end
end
