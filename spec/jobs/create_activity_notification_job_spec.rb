# frozen_string_literal: true

RSpec.describe CreateActivityNotificationJob, type: :job do
  let!(:guild) { create :guild }
  let!(:time_offset) { create :time_offset, timeable: guild }
  let!(:activity) { create :activity, guild: guild }
  let!(:guild_notification) { create :notification, event: 'activity_creation', status: 0 }
  let!(:user_notification) { create :notification, event: 'activity_creation', status: 1 }

  it 'executes Notifies::CreateActivity.call' do
    expect_any_instance_of(Notifies::CreateActivity).to receive(:call).and_call_original

    described_class.perform_now(activity_id: activity.id)
  end
end
