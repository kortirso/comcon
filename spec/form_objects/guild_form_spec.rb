RSpec.describe GuildForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { GuildForm.new(name: '') }

      it 'does not create new guild' do
        expect { service.persist? }.to_not change(Guild, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:guild) { create :guild }

      context 'for existed guild' do
        let(:service) { GuildForm.new(name: guild.name, world: guild.world) }

        it 'does not create new guild' do
          expect { service.persist? }.to_not change(Guild, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted guild' do
        let(:service) { GuildForm.new(name: 'Хроми', world: guild.world) }

        it 'creates new guild' do
          expect { service.persist? }.to change { Guild.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:guild1) { create :guild }
      let!(:guild2) { create :guild, world: guild1.world }

      context 'for unexisted guild' do
        let(:service) { GuildForm.new(id: 999, name: '1') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed guild' do
        context 'for invalid data' do
          let(:service) { GuildForm.new(id: guild1.id, name: '', world: guild1.world) }

          it 'does not update guild' do
            service.persist?
            guild1.reload

            expect(guild1.name).to_not eq ''
          end
        end

        context 'for existed data' do
          let(:service) { GuildForm.new(id: guild1.id, name: guild2.name, world: guild1.world) }

          it 'does not update guild' do
            service.persist?
            guild1.reload

            expect(guild1.name).to_not eq guild2.name
          end
        end

        context 'for valid data' do
          let(:service) { GuildForm.new(id: guild1.id, name: 'Хроми', world: guild1.world) }

          it 'does not update guild' do
            service.persist?
            guild1.reload

            expect(guild1.name).to eq 'Хроми'
          end
        end
      end
    end
  end
end
