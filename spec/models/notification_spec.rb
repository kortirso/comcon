# frozen_string_literal: true

RSpec.describe Notification, type: :model do
  it { is_expected.to have_many(:deliveries).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    notification = build :notification

    expect(notification).to be_valid
  end

  describe '.content' do
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

    context 'for guild_request_creation_content' do
      let!(:guild_invite) { create :guild_invite }
      let!(:notification) { create :notification, event: 'guild_request_creation' }

      it 'returns string' do
        expect(notification.content(event_object: guild_invite).is_a?(String)).to eq true
      end
    end

    context 'for bank_request_creation_content' do
      let!(:bank_request) { create :bank_request }
      let!(:notification) { create :notification, event: 'bank_request_creation' }

      it 'returns string' do
        expect(notification.content(event_object: bank_request).is_a?(String)).to eq true
      end
    end

    context 'for activity_creation_content' do
      let!(:activity) { create :activity }
      let!(:notification) { create :notification, event: 'activity_creation' }

      it 'returns string' do
        expect(notification.content(event_object: activity).is_a?(String)).to eq true
      end
    end

    describe '.render_start_time' do
      let!(:notification) { create :notification, event: 'guild_static_event_creation' }

      it 'returns string' do
        expect(notification.send(:render_start_time, event: event).is_a?(String)).to eq true
      end
    end
  end
end
