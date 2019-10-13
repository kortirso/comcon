RSpec.describe DungeonForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { DungeonForm.new(name: '') }

      it 'does not create new dungeon' do
        expect { service.persist? }.to_not change(Dungeon, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:dungeon) { create :dungeon }

      context 'for existed dungeon' do
        let(:service) { DungeonForm.new(name: dungeon.name) }

        it 'does not create new dungeon' do
          expect { service.persist? }.to_not change(Dungeon, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted dungeon' do
        let(:service) { DungeonForm.new(name: 'Крутогора') }

        it 'creates new dungeon' do
          expect { service.persist? }.to change { Dungeon.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:dungeon1) { create :dungeon }
      let!(:dungeon2) { create :dungeon }

      context 'for unexisted dungeon' do
        let(:service) { DungeonForm.new(id: 999, name: '1') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed dungeon' do
        context 'for invalid data' do
          let(:service) { DungeonForm.new(id: dungeon1.id, name: '') }

          it 'does not update dungeon' do
            service.persist?
            dungeon1.reload

            expect(dungeon1.name).to_not eq ''
          end
        end

        context 'for existed data' do
          let(:service) { DungeonForm.new(id: dungeon1.id, name: dungeon2.name) }

          it 'does not update dungeon' do
            service.persist?
            dungeon1.reload

            expect(dungeon1.name).to_not eq dungeon2.name
          end
        end

        context 'for valid data' do
          let(:service) { DungeonForm.new(id: dungeon1.id, name: 'Хромогора') }

          it 'does not update dungeon' do
            service.persist?
            dungeon1.reload

            expect(dungeon1.name).to eq 'Хромогора'
          end
        end
      end
    end
  end
end
