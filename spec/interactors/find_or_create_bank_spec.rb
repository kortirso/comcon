# frozen_string_literal: true

describe FindOrCreateBank do
  let!(:guild) { create :guild }
  let(:bank_data) do
    'W9CS0L7RgdGC0L7QutCx0LDQvdC6LDExNTI1NCxydVJVXTtbLTEsLDAs0KDRjtC60LfQsNC6LDEs0JfQsNC/0LvQtdGH0L3Ri9C5INC80LXRiNC+0Log0L/QvtC00LzQsNGB0YLQtdGA0YzRjywyLNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCwzLNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw0LNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw1LNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw2LNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw3LCw4LCw5LCwxMCwsMTEsLDEyLF07Wy0xLDEsMTEzNzAsMTBdO1stMSwyLDExMzcwLDNdO1stMSwzLDExMzcwLDEwXTtbLTEsNCwxMTM3MCwxMF07Wy0xLDUsMTEzNzAsMTBdO1stMSw2LDExMzcwLDEwXTtbLTEsNywxMTM3MCwxMF07Wy0xLDgsMTEzNzAsMTBdO1stMSw5LDExMzcwLDEwXTtbLTEsMTAsMTEzNzAsMTBdO1swLDEsMTY4MjgsMV07WzAsMiwxNjgyOCwxXTtbMCwzLDE2ODMwLDFdO1swLDQsMTY4MDIsMV07WzAsNSwxNjgwMiwxXTtbMCw2LDE0MzQxLDE2XTtbMCw3LDE0MDQ4LDEwXTtbMCw4LDE0MDQ4LDEwXTtbMCw5LDE0MDQ4LDEwXTtbMCwxMCwxNDA0OCwxMF07WzIsMSw3MDc4LDEwXTtbMiwyLDcwNzgsMTBdO1syLDMsNzA3OCwxMF07WzIsNCw3MDc4LDEwXTtbMiw1LDcwNzgsMTBdO1syLDYsNzA3OCwxXTtbMiw3LDcwNzcsMV07WzIsOCw3MDc3LDEwXTtbMiw5LDcwNzcsMTBdO1syLDEwLDcwNzcsMTBdO1syLDExLDcwNjgsMTBdO1syLDEyLDcwNjgsMTBdO1syLDEzLDcwNjgsMTBdO1syLDE0LDcwNjgsMTBdO1szLDEsNzA2OCw1XTtbMywyLDExMzgyLDJdO1szLDMsMTQzNDEsMTddO1szLDQsMTQzNDEsMjBdO1szLDcsNzA3Niw5XTtbMyw4LDE0MDQ4LDEwXTtbMyw5LDE0MzQxLDIwXTtbMywxMCwxNDA0OCwxMF07WzMsMTEsMTQwNDgsMTBdO1szLDEyLDE0MDQ4LDEwXTtbMywxMywxNDA0OCwxMF07WzMsMTQsMTQwNDgsMTBdO1s0LDUsMTQwNDYsMV07WzQsNiwzOTE0LDFdO1s0LDcsMzkxNCwxXTtbNCw4LDE0MDQ4LDVdO1s0LDksMTQwNDgsMTBdO1s1LDEsMTcwMTAsNF07WzUsMiwxNzAxMCwxMF07WzUsMywxNzAxMCwxMF07WzUsNCwxNzAxMCwxMF07WzUsNSwxNzAxMCwxMF07WzUsMTAsMTcwMTEsMl07WzUsMTEsMTcwMTEsMTBdO1s1LDEyLDE3MDExLDEwXTtbNSwxMywxNzAxMSw4XTtbNSwxNCwxNzAxMSwxMF07WzYsMSwxNTQxMCwyMF07WzYsMiwxNTQxMCwzXTtbNiw0LDE3MDEyLDIwXTtbNiw1LDE3MDEyLDIwXTtbNiw2LDE3MDEyLDIwXTtbNiw3LDE3MDEyLDIwXTtbNiw4LDE3MDEyLDExXTtbNiwxMywxNDM0NCwyMF07WzYsMTQsMTQzNDQsOF07'
  end

  let(:bank_data) do
    'W9CS0L7RgdGC0L7QutCx0LDQvdC6LDExNTI1NCxydVJVXTtbLTEsLDAs0KDRjtC60LfQsNC6LDEs0JfQsNC/0LvQtdGH0L3Ri9C5INC80LXRiNC+0Log0L/QvtC00LzQsNGB0YLQtdGA0YzRjywyLNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCwzLNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw0LNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw1LNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw2LNCh0YPQvNC60LAg0LjQtyDRgNGD0L3QvdC+0Lkg0YLQutCw0L3QuCw3LCw4LCw5LCwxMCwsMTEsLDEyLF07Wy0xLDEsMTEzNzAsMTBdO1stMSwyLDExMzcwLDNdO1stMSwzLDExMzcwLDEwXTtbLTEsNCwxMTM3MCwxMF07Wy0xLDUsMTEzNzAsMTBdO1stMSw2LDExMzcwLDEwXTtbLTEsNywxMTM3MCwxMF07Wy0xLDgsMTEzNzAsMTBdO1stMSw5LDExMzcwLDEwXTtbLTEsMTAsMTEzNzAsMTBdO1swLDEsMTY4MjgsMV07WzAsMiwxNjgyOCwxXTtbMCwzLDE2ODMwLDFdO1swLDQsMTY4MDIsMV07WzAsNSwxNjgwMiwxXTtbMCw2LDE0MzQxLDE2XTtbMCw3LDE0MDQ4LDEwXTtbMCw4LDE0MDQ4LDEwXTtbMCw5LDE0MDQ4LDEwXTtbMCwxMCwxNDA0OCwxMF07WzIsMSw3MDc4LDEwXTtbMiwyLDcwNzgsMTBdO1syLDMsNzA3OCwxMF07WzIsNCw3MDc4LDEwXTtbMiw1LDcwNzgsMTBdO1syLDYsNzA3OCwxXTtbMiw3LDcwNzcsMV07WzIsOCw3MDc3LDEwXTtbMiw5LDcwNzcsMTBdO1syLDEwLDcwNzcsMTBdO1syLDExLDcwNjgsMTBdO1syLDEyLDcwNjgsMTBdO1syLDEzLDcwNjgsMTBdO1syLDE0LDcwNjgsMTBdO1szLDEsNzA2OCw1XTtbMywyLDExMzgyLDJdO1szLDMsMTQzNDEsMTddO1szLDQsMTQzNDEsMjBdO1szLDcsNzA3Niw5XTtbMyw4LDE0MDQ4LDEwXTtbMyw5LDE0MzQxLDIwXTtbMywxMCwxNDA0OCwxMF07WzMsMTEsMTQwNDgsMTBdO1szLDEyLDE0MDQ4LDEwXTtbMywxMywxNDA0OCwxMF07WzMsMTQsMTQwNDgsMTBdO1s0LDUsMTQwNDYsMV07WzQsNiwzOTE0LDFdO1s0LDcsMzkxNCwxXTtbNCw4LDE0MDQ4LDVdO1s0LDksMTQwNDgsMTBdO1s1LDEsMTcwMTAsNF07WzUsMiwxNzAxMCwxMF07WzUsMywxNzAxMCwxMF07WzUsNCwxNzAxMCwxMF07WzUsNSwxNzAxMCwxMF07WzUsMTAsMTcwMTEsMl07WzUsMTEsMTcwMTEsMTBdO1s1LDEyLDE3MDExLDEwXTtbNSwxMywxNzAxMSw4XTtbNSwxNCwxNzAxMSwxMF07WzYsMSwxNTQxMCwyMF07WzYsMiwxNTQxMCwzXTtbNiw0LDE3MDEyLDIwXTtbNiw1LDE3MDEyLDIwXTtbNiw2LDE3MDEyLDIwXTtbNiw3LDE3MDEyLDIwXTtbNiw4LDE3MDEyLDExXTtbNiwxMywxNDM0NCwyMF07WzYsMTQsMTQzNDQsOF07'
  end

  describe '.call' do
    context 'for invalid bank data' do
      let(:interactor) { described_class.call(guild: guild, bank_data: '') }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create new bank' do
        expect { interactor }.not_to change(Bank, :count)
      end
    end

    context 'for valid params' do
      let(:interactor) { described_class.call(guild: guild, bank_data: bank_data) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates new bank' do
        expect { interactor }.to change(Bank, :count).by(1)
      end

      it 'and provides bank' do
        expect(interactor.bank).to eq Bank.last
      end
    end

    context 'for valid params, for existed bank' do
      let!(:bank) { create :bank, guild: guild, name: 'Востокбанк', coins: 0 }
      let(:interactor) { described_class.call(guild: guild, bank_data: bank_data) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not create new bank' do
        expect { interactor }.not_to change(Bank, :count)
      end

      it 'and updates bank' do
        interactor
        bank.reload

        expect(bank.coins).to eq 115_254
      end

      it 'and provides bank' do
        expect(interactor.bank.id).to eq bank.id
      end
    end
  end
end
