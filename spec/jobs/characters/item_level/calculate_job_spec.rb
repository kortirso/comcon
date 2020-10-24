# frozen_string_literal: true

RSpec.describe Characters::ItemLevel::CalculateJob, type: :job do
  before do
    allow(::Characters::ItemLevel::CalculateService).to receive(:call)
  end

  it 'executes Characters::ItemLevel::CalculateService.call' do
    described_class.perform_now

    expect(::Characters::ItemLevel::CalculateService).to have_received(:call)
  end
end
