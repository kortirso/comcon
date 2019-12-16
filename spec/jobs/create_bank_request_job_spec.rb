RSpec.describe CreateBankRequestJob, type: :job do
  let!(:character) { create :character }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction }
  let!(:bank) { create :bank, guild: guild }
  let!(:bank_request) { create :bank_request, bank: bank }
  let!(:notification1) { create :notification, event: 'bank_request_creation', status: 0 }
  let!(:notification2) { create :notification, event: 'bank_request_creation', status: 1 }
  let!(:delivery) { create :delivery, deliveriable: guild, notification: notification1 }

  it 'executes Notifies::CreateBankRequest.call' do
    expect_any_instance_of(Notifies::CreateBankRequest).to receive(:call).and_call_original

    described_class.perform_now(bank_request_id: bank_request.id)
  end
end
