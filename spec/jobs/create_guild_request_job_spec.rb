# frozen_string_literal: true

RSpec.describe CreateGuildRequestJob, type: :job do
  let!(:character) { create :character }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction }
  let!(:guild_invite) { create :guild_invite, character: character, guild: guild }
  let!(:notification1) { create :notification, event: 'guild_request_creation', status: 0 }
  let!(:notification2) { create :notification, event: 'guild_request_creation', status: 1 }
  let!(:delivery) { create :delivery, deliveriable: guild, notification: notification1 }

  it 'executes Notifies::CreateGuildRequest.call' do
    expect_any_instance_of(Notifies::CreateGuildRequest).to receive(:call).and_call_original

    described_class.perform_now(guild_invite_id: guild_invite.id)
  end
end
