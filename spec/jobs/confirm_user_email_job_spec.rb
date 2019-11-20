RSpec.describe ConfirmUserEmailJob, type: :job do
  let!(:user) { create :user }

  it 'executes method confirmation_email of UserMailer' do
    expect(UserMailer).to receive(:confirmation_email).and_call_original

    described_class.perform_now(user_id: user.id)
  end
end
