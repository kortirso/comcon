describe CreateIdentity do
  let!(:user) { create :user }

  describe '.call' do
    context 'for existed identity' do
      let!(:identity) { create :identity, user: user }
      let(:interactor) { CreateIdentity.call(uid: identity.uid, provider: identity.provider, user: user, email: '') }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create identity' do
        expect { interactor }.to_not change(Identity, :count)
      end
    end

    context 'for unexisted identity' do
      let(:interactor) { CreateIdentity.call(uid: '123', provider: 'discord', user: user, email: '') }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates identity' do
        expect { interactor }.to change { user.identities.count }.by(1)
      end
    end
  end
end
