RSpec.describe Oauth, type: :service do
  describe '.auth_login' do
    let!(:oauth) { create :oauth, :with_credentials }
    let(:request) { Oauth.auth_login(auth: oauth) }

    context 'for unexisted user and identity' do
      it 'creates new User' do
        expect { request }.to change(User, :count).by(1)
      end

      it 'and returns new User' do
        expect(request).to eq User.last
      end

      it 'and calls CreateIdentity' do
        expect(CreateIdentity).to receive(:call).and_call_original

        request
      end

      it 'and creates new Identity' do
        expect { request }.to change(Identity, :count).by(1)
      end

      it 'and new Identity has params from oauth and belongs to new User' do
        user = request
        identity = Identity.last

        expect(identity.uid).to eq oauth.uid
        expect(identity.provider).to eq oauth.provider
        expect(identity.user).to eq user
      end
    end

    context 'for existed user without identity' do
      let!(:user) { create :user, email: oauth.info[:email] }

      it 'does not create new User' do
        expect { request }.to_not change(User, :count)
      end

      it 'and returns existed user' do
        expect(request).to eq user
      end

      it 'and calls CreateIdentity' do
        expect(CreateIdentity).to receive(:call).and_call_original

        request
      end

      it 'and creates new Identity' do
        expect { request }.to change(Identity, :count).by(1)
      end

      it 'and new Identity has params from oauth and belongs to existed user' do
        request
        identity = Identity.last

        expect(identity.uid).to eq oauth.uid
        expect(identity.provider).to eq oauth.provider
        expect(identity.user).to eq user
      end
    end

    context 'for existed user with identity' do
      let!(:user) { create :user, email: oauth.info[:email] }
      let!(:identity) { create :identity, uid: oauth.uid, user: user }

      it 'does not create new User' do
        expect { request }.to_not change(User, :count)
      end

      it 'and returns existed user' do
        expect(request).to eq user
      end

      it 'and does not create new Identity' do
        expect { request }.to_not change(Identity, :count)
      end
    end
  end

  describe '.auth_binding' do
    let!(:user) { create :user }
    let!(:oauth) { create :oauth, :with_credentials }
    let(:request) { Oauth.auth_binding(auth: oauth, user: user) }

    context 'for existed identity' do
      let!(:identity) { create :identity, user: user, uid: '1234567890' }

      it 'does not create new Identity' do
        expect { request }.to_not change(Identity, :count)
      end

      it 'and returns nil' do
        expect(request.nil?).to eq true
      end
    end

    context 'for unexisted identity' do
      it 'and calls CreateIdentity' do
        expect(CreateIdentity).to receive(:call).and_call_original

        request
      end

      it 'and new Identity has params from oauth and belongs to existed user' do
        request
        identity = Identity.last

        expect(identity.uid).to eq oauth.uid
        expect(identity.provider).to eq oauth.provider
        expect(identity.user).to eq user
      end
    end
  end
end
