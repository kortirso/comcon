# frozen_string_literal: true

describe CreateResetToken do
  let!(:user) { create :user }
  let(:interactor) { described_class.call(user: user) }

  describe '.call' do
    it 'succeeds' do
      expect(interactor).to be_a_success
    end

    it 'and provides the user' do
      expect(interactor.user).to eq user
    end

    it "and updates the user's reset token" do
      expect(interactor.user.reset_password_token).not_to eq nil
    end
  end

  describe '.rollback' do
    subject(:interactor) { described_class.new(user: user) }

    it 'removes the token' do
      interactor.call
      interactor.rollback
      user.reload

      expect(user.reset_password_token).to eq nil
      expect(user.reset_password_token_sent_at).to eq nil
    end
  end
end
