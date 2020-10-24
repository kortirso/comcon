# frozen_string_literal: true

describe ValidateUserEmail do
  let!(:user) { create :user, :unconfirmed }

  describe '.call' do
    context 'for invalid token' do
      let!(:confirmed_user) { create :user }
      let(:interactor) { described_class.call(user: confirmed_user, confirmation_token: confirmed_user.confirmation_token) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end
    end

    context 'for invalid token' do
      let(:interactor) { described_class.call(user: user, confirmation_token: '') }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not update user' do
        interactor
        user.reload

        expect(user.confirmed?).to eq false
      end
    end

    context 'for valid token' do
      let(:interactor) { described_class.call(user: user, confirmation_token: user.confirmation_token) }

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
