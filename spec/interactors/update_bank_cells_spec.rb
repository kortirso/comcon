describe UpdateBankCells do
  let!(:bank) { create :bank }
  let!(:cells_info) { ['[-1,1,11370,10]', '[-1,2,11370,3]', '[-1,3,11370,10]', '[-1,4,11370,10]', '[-1,5,11370,10]', '[-1,6,11370,10]', '[-1,7,11370,10]', '[-1,8,11370,10]', '[-1,9,11370,10]', '[-1,10,11370,10]', '[0,1,16828,1]', '[0,2,16828,1]', '[0,3,16830,1]', '[0,4,16802,1]', '[0,5,16802,1]', '[0,6,14341,16]', '[0,7,14048,10]', '[0,8,14048,10]', '[0,9,14048,10]', '[0,10,14048,10]', '[2,1,7078,10]', '[2,2,7078,10]', '[2,3,7078,10]', '[2,4,7078,10]', '[2,5,7078,10]', '[2,6,7078,1]', '[2,7,7077,1]', '[2,8,7077,10]', '[2,9,7077,10]', '[2,10,7077,10]', '[2,11,7068,10]', '[2,12,7068,10]', '[2,13,7068,10]', '[2,14,7068,10]', '[3,1,7068,5]', '[3,2,11382,2]', '[3,3,14341,17]', '[3,4,14341,20]', '[3,7,7076,9]', '[3,8,14048,10]', '[3,9,14341,20]', '[3,10,14048,10]', '[3,11,14048,10]', '[3,12,14048,10]', '[3,13,14048,10]', '[3,14,14048,10]', '[4,5,14046,1]', '[4,6,3914,1]', '[4,7,3914,1]', '[4,8,14048,5]', '[4,9,14048,10]', '[5,1,17010,4]', '[5,2,17010,10]', '[5,3,17010,10]', '[5,4,17010,10]', '[5,5,17010,10]', '[5,10,17011,2]', '[5,11,17011,10]', '[5,12,17011,10]', '[5,13,17011,8]', '[5,14,17011,10]', '[6,1,15410,20]', '[6,2,15410,3]', '[6,4,17012,20]', '[6,5,17012,20]', '[6,6,17012,20]', '[6,7,17012,20]', '[6,8,17012,11]', '[6,13,14344,20]', '[6,14,14344,8]'] }

  describe '.call' do
    let(:interactor) { described_class.call(bank: bank, cells_info: cells_info) }

    it 'succeeds' do
      expect(interactor).to be_a_success
    end

    it 'and calls UpdateBankCellsJob' do
      expect(UpdateBankCellsJob).to receive(:perform_now).and_call_original

      interactor
    end
  end
end
