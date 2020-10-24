# frozen_string_literal: true

describe UpdateUserPassword do
  let!(:user) { create :user }

  describe '.call' do
    context 'for unequal passwords' do
      let(:interactor) { described_class.call(user: user, user_password_params: { password: '123', password_confirmation: '1234' }) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not update user password' do
        interactor
        user.reload

        expect(user.valid_password?('123')).to eq false
      end
    end

    context 'for invalid passwords' do
      let(:interactor) { described_class.call(user: user, user_password_params: { password: '123', password_confirmation: '123' }) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not update user password' do
        interactor
        user.reload

        expect(user.valid_password?('123')).to eq false
      end
    end

    context 'for valid passwords' do
      let(:interactor) { described_class.call(user: user, user_password_params: { password: '1234567890', password_confirmation: '1234567890' }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates user password' do
        interactor
        user.reload

        expect(user.valid_password?('1234567890')).to eq true
      end
    end
  end
end
