# frozen_string_literal: true

RSpec.describe NotifyComingSoonEventsJob, type: :job do
  it 'executes Notifies::ComingSoonEvents.call' do
    expect_any_instance_of(Notifies::ComingSoonEvents).to receive(:call).and_call_original

    described_class.perform_now
  end
end
