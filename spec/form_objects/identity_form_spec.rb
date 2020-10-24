# frozen_string_literal: true

RSpec.describe IdentityForm, type: :service do
  let!(:user) { create :user }

  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(uid: nil, provider: nil, user: user, email: '') }

      it 'does not create new identity' do
        expect { service.persist? }.not_to change(Identity, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      context 'for existed identity' do
        let!(:identity) { create :identity }
        let(:service) { described_class.new(uid: identity.uid, provider: identity.provider, user: user, email: '') }

        it 'does not create new identity' do
          expect { service.persist? }.not_to change(Identity, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted identity' do
        let(:service) { described_class.new(uid: '123', provider: 'discord', user: user, email: '') }

        it 'creates new identity' do
          expect { service.persist? }.to change(Identity, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
