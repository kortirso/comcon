# frozen_string_literal: true

RSpec.describe ResetPasswordEmailJob, type: :job do
  let!(:user) { create :user }

  it 'executes method reset_password_email of UserMailer' do
    expect(UserMailer).to receive(:reset_password_email).and_call_original

    described_class.perform_now(user_id: user.id)
  end
end
