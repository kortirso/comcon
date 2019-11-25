RSpec.describe UserMailer, type: :mailer do
  describe 'confirmation_email' do
    let!(:user) { create :user }
    let(:mail) { UserMailer.confirmation_email(user_id: user.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('mailer.user.confirmation_email.subject'))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['support@guild-hall.org'])
    end
  end

  describe 'reset_password_email' do
    let!(:user) { create :user }
    let(:mail) { UserMailer.reset_password_email(user_id: user.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('mailer.user.reset_password_email.subject'))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['support@guild-hall.org'])
    end
  end
end
