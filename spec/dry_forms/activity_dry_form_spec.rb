RSpec.describe ActivityDryForm, type: :service do
  let!(:guild) { create :guild }

  describe '.save' do
    context 'for invalid data' do
      let(:service) { described_class.new(id: nil, title: '', description: '', guild: nil) }

      it 'does not create new activity' do
        expect { service.save }.to_not change(Activity, :count)
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
      let(:service) { described_class.new(id: nil, title: '1', description: '2', guild: guild) }

      it 'creates new activity' do
        expect { service.save }.to change { guild.activities.count }.by(1)
      end

      it 'and returns true' do
        expect(service.save).to eq true
      end

      it 'and form contains created activity' do
        service.save

        expect(service.activity).to eq Activity.last
      end
    end

    context 'for updating' do
      let!(:activity) { create :activity, guild: guild }

      context 'for invalid data' do
        let(:service) { described_class.new(activity.attributes.symbolize_keys.merge(guild: activity.guild, title: '')) }

        it 'does not update activity' do
          service.save
          activity.reload

          expect(activity.title).to_not eq ''
        end

        it 'and form contains errors' do
          service.save

          expect(service.errors.size.positive?).to eq true
        end
      end

      context 'for valid data' do
        let(:service) { described_class.new(activity.attributes.symbolize_keys.merge(guild: activity.guild, title: 'Хроми')) }

        it 'does not update activity' do
          service.save
          activity.reload

          expect(activity.title).to eq 'Хроми'
        end

        it 'and returns true' do
          expect(service.save).to eq true
        end

        it 'and form contains updated activity' do
          service.save

          expect(service.activity.id).to eq activity.id
        end
      end
    end
  end
end
