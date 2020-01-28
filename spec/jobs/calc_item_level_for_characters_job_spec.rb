RSpec.describe CalcItemLevelForCharactersJob, type: :job do
  it 'executes CalcItemLevelForCharacters.new.call' do
    expect_any_instance_of(CalcItemLevelForCharacters).to receive(:call).and_call_original

    described_class.perform_now
  end
end
