RSpec.describe Notification, type: :model do
  it { should have_many(:deliveries).dependent(:destroy) }

  it 'factory should be valid' do
    notification = build :notification

    expect(notification).to be_valid
  end

  context '.content' do
    let!(:event) { create :event }

    context 'for guild_event_creation' do
      let!(:notification) { create :notification, event: 'guild_event_creation' }

      it 'returns string' do
        expect(notification.content(event_object: event).is_a?(String)).to eq true
      end
    end

    context 'for event_start_soon' do
      let!(:notification) { create :notification, event: 'event_start_soon' }

      it 'returns string' do
        expect(notification.content(event_object: event).is_a?(String)).to eq true
      end
    end

    context 'for guild_static_event_creation' do
      let!(:notification) { create :notification, event: 'guild_static_event_creation' }

      it 'returns string' do
        expect(notification.content(event_object: event).is_a?(String)).to eq true
      end
    end

    context '.render_start_time' do
      let!(:notification) { create :notification, event: 'guild_static_event_creation' }

      it 'returns string' do
        expect(notification.send(:render_start_time, event: event).is_a?(String)).to eq true
      end
    end
  end
end
