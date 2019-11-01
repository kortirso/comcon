RSpec.describe StaticForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { StaticForm.new(name: '', guild: nil) }

      it 'does not create new static' do
        expect { service.persist? }.to_not change(Guild, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:static) { create :static, :guild }

      context 'for existed static' do
        let(:service) { StaticForm.new(name: static.name, staticable_id: static.staticable_id, staticable_type: 'Guild') }

        it 'does not create new static' do
          expect { service.persist? }.to_not change(Static, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted static' do
        let!(:guild) { create :guild }
        let(:service) { StaticForm.new(name: '123', staticable_id: guild.id, staticable_type: 'Guild') }

        it 'creates new static' do
          expect { service.persist? }.to change { guild.statics.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
