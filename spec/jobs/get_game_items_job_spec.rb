RSpec.describe GetGameItemsJob, type: :job do
  it 'executes GetGameItemsForBankCells.new.call' do
    expect_any_instance_of(GetGameItemsForBankCells).to receive(:call).and_call_original

    described_class.perform_now
  end
end
