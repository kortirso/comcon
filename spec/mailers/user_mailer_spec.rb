RSpec.describe UserMailer, type: :mailer do
  describe 'confirmation_email' do
    let!(:user) { create :user }
    let(:mail) { UserMailer.confirmation_email(user_id: user.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Пожалуйста, подтвердите ваш почтовый адрес для Guild-Hall.org')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['support@guild-hall.org'])
    end
  end
end
