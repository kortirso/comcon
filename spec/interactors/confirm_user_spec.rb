# frozen_string_literal: true

describe ConfirmUser do
  let!(:user) { create :user }

  describe '.call' do
    context 'for confirmed user' do
      let!(:user) { create :user }
      let(:interactor) { described_class.call(user: user) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end
    end

    context 'for unconfirmed user' do
      let!(:user) { create :user, :unconfirmed }
      let(:interactor) { described_class.call(user: user) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates user' do
        interactor
        user.reload

        expect(user.confirmed?).to eq true
      end
    end
  end
end
