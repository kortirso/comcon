describe UpdateTimeOffset do
  let!(:user) { create :user }

  describe '.call' do
    context 'for empty value' do
      let(:interactor) { described_class.call(timeable: user, value: '') }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'update value param to nil' do
        interactor
        user.reload

        expect(user.time_offset.value).to eq nil
      end
    end

    context 'for not empty value' do
      let(:interactor) { described_class.call(timeable: user, value: '3') }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'update value param to 3' do
        interactor
        user.reload

        expect(user.time_offset.value).to eq 3
      end
    end
  end
end
