RSpec.describe SubscribeForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { SubscribeForm.new(name: '') }

      it 'does not create new subscribe' do
        expect { service.persist? }.to_not change(Subscribe, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:event) { create :event }
      let!(:character) { create :character }
      let(:service) { SubscribeForm.new(event: event, character: character) }

      it 'creates new subscribe' do
        expect { service.persist? }.to change { Subscribe.count }.by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:subscribe) { create :subscribe }

      context 'for unexisted subscribe' do
        let(:service) { SubscribeForm.new(id: 999, approved: true) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for valid data' do
        let(:service) { SubscribeForm.new(subscribe.attributes.merge(event: subscribe.event, character: subscribe.character, approved: true)) }

        it 'does not update guild' do
          service.persist?
          subscribe.reload

          expect(subscribe.approved).to eq true
        end
      end
    end
  end
end
