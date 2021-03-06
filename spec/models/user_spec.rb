# frozen_string_literal: true

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:characters).dependent(:destroy) }
  it { is_expected.to have_many(:guilds).through(:characters) }
  it { is_expected.to have_many(:subscribes).through(:characters) }
  it { is_expected.to have_many(:worlds).through(:characters) }
  it { is_expected.to have_many(:static_members).through(:characters) }
  it { is_expected.to have_many(:world_fractions).through(:characters) }
  it { is_expected.to have_many(:identities).dependent(:destroy) }
  it { is_expected.to have_one(:time_offset).dependent(:destroy) }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :password }
  it { is_expected.to validate_presence_of :role }
  it { is_expected.to validate_inclusion_of(:role).in_array(%w[user admin]) }

  it 'factory is_expected.to be valid' do
    user = build :user

    expect(user).to be_valid
  end

  it 'is_expected.to be invalid without email' do
    user = described_class.new(email: nil)
    user.valid?

    expect(user.errors[:email]).not_to eq nil
  end

  it 'is_expected.to be invalid without password' do
    user = described_class.new(password: nil)
    user.valid?

    expect(user.errors[:password]).not_to eq nil
  end

  it 'is_expected.to be invalid with a duplicate email' do
    described_class.create(email: 'example@gmail.com', password: 'password12')
    user = described_class.new(email: 'example@gmail.com', password: 'password12')
    user.valid?

    expect(user.errors[:email]).not_to eq nil
  end

  describe 'methods' do
    describe '.create_time_offset' do
      it 'creates time_offset' do
        expect { create :user }.to change(TimeOffset, :count).by(1)
      end
    end

    describe '.confirmed?' do
      it 'returns false for user with unconfirmed email' do
        user = create :user, :unconfirmed

        expect(user.confirmed?).to eq false
      end

      it 'returns true for user with confirmed email' do
        user = create :user

        expect(user.confirmed?).to eq true
      end
    end

    describe '.is_admin?' do
      it 'returns false for user' do
        user = create :user

        expect(user.is_admin?).to eq false
      end

      it 'returns true for admin' do
        user = create :user, :admin

        expect(user.is_admin?).to eq true
      end
    end

    describe '.any_role?' do
      let!(:user1) { create :user }
      let!(:user2) { create :user }
      let!(:user3) { create :user }
      let!(:guild) { create :guild }
      let!(:character1) { create :character, guild: guild, user: user2 }
      let!(:character2) { create :character, guild: guild, user: user3 }
      let!(:guild_role1) { create :guild_role, guild: guild, character: character1, name: 'rl' }
      let!(:guild_role2) { create :guild_role, guild: guild, character: character2, name: 'gm' }

      it 'returns false for user without characters in guild' do
        result = user1.any_role?(guild.id, 'gm')

        expect(result).to eq false
      end

      it 'returns false for user with characters in guild, but no gm' do
        result = user2.any_role?(guild.id, 'gm')

        expect(result).to eq false
      end

      it 'returns true for user with gm characters in guild' do
        result = user3.any_role?(guild.id, 'gm')

        expect(result).to eq true
      end
    end

    describe '.any_character_in_static?' do
      let!(:character) { create :character }
      let!(:static1) { create :static, :guild, world: character.world, fraction: character.race.fraction }
      let!(:static2) { create :static, :guild, world: character.world, fraction: character.race.fraction }
      let!(:static_member) { create :static_member, static: static1, character: character }

      it 'returns true if user has character in static' do
        result = character.user.any_character_in_static?(static1)

        expect(result).to eq true
      end

      it 'returns false if user has no character in static' do
        result = character.user.any_character_in_static?(static2)

        expect(result).to eq false
      end
    end

    describe '.statics' do
      let!(:character) { create :character }
      let!(:static1) { create :static, :guild, world: character.world, fraction: character.race.fraction }
      let!(:static2) { create :static, :guild, world: character.world, fraction: character.race.fraction }
      let!(:static_member) { create :static_member, static: static1, character: character }

      it 'returns only statics where user character has membership' do
        result = character.user.statics

        expect(result.size).to eq 1
        expect(result[0].id).to eq static1.id
      end
    end

    describe '.remember' do
      let!(:user) { create :user }

      it 'updates remember_digest param from nil' do
        expect { user.remember }.to change(user, :remember_digest).from(nil)
      end
    end

    describe '.forget' do
      let!(:user) { create :user }

      before { user.remember }

      it 'updates remember_digest param to nil' do
        expect { user.forget }.to change(user, :remember_digest).to(nil)
      end
    end

    describe '.authenticated?' do
      let!(:user) { create :user, remember_digest: nil }

      it 'returns false for nil remember_digest' do
        expect(user.authenticated?('')).to eq false
      end

      it 'returns false for wrong digest/token' do
        token = SecureRandom.urlsafe_base64
        user.update_attribute(:remember_digest, described_class.digest(token))

        expect(user.authenticated?("#{token}1")).to eq false
      end

      it 'returns true for correct digest' do
        token = SecureRandom.urlsafe_base64
        user.update_attribute(:remember_digest, described_class.digest(token))

        expect(user.authenticated?(token)).to eq true
      end
    end

    describe '.available_characters_for_event' do
      let!(:user) { create :user }
      let!(:character1) { create :character, user: user }
      let!(:character2) { create :character, user: user }
      let!(:character3) { create :character, user: user }
      let!(:guild) { create :guild, world: character2.world, fraction: character2.race.fraction, world_fraction: character2.world_fraction }
      let!(:world_event) { create :event, eventable: character1.world, fraction: character1.race.fraction, world_fraction: character1.world_fraction }
      let!(:guild_event) { create :event, eventable: guild, fraction: character2.race.fraction, world_fraction: character2.world_fraction }
      let!(:static) { create :static, staticable: character3 }
      let!(:static_member) { create :static_member, character: character3, static: static }
      let!(:static_event) { create :event, eventable: static, fraction: character3.race.fraction, world_fraction: character3.world_fraction }

      it 'returns characters for world event' do
        result = user.available_characters_for_event(event: world_event)

        expect(result.size).to eq 1
        expect(result[0]).to eq character1
      end

      it 'returns characters for guild event' do
        character2.update(guild_id: guild.id)

        result = user.available_characters_for_event(event: guild_event)

        expect(result.size).to eq 1
        expect(result[0]).to eq character2
      end

      it 'returns characters for static event' do
        result = user.available_characters_for_event(event: static_event)

        expect(result.size).to eq 1
        expect(result[0]).to eq character3
      end
    end

    describe '.has_characters_in_guild?' do
      let!(:user) { create :user }
      let!(:guild1) { create :guild }
      let!(:character) { create :character, user: user }
      let!(:guild2) { create :guild, world: character.world, fraction: character.race.fraction }

      it 'returns false for no characters in guild' do
        expect(user.has_characters_in_guild?(guild_id: guild1.id)).to eq false
      end

      it 'returns true for characters in guild' do
        character.update(guild_id: guild2.id)

        expect(user.has_characters_in_guild?(guild_id: guild2.id)).to eq true
      end
    end

    describe '.generate_token' do
      let!(:user) { create :user }

      it 'updates token' do
        expect { user.send(:generate_token) }.to change(user, :token).from(nil)
      end

      it 'and returns token' do
        expect(user.send(:generate_token).is_a?(String)).to eq true
      end
    end

    describe '.access_token' do
      let!(:user) { create :user }

      it 'returns user token if token is nil' do
        expect(user.access_token).to eq user.token
      end
    end

    describe '.token_expired?' do
      let!(:user) { create :user }

      context 'for expired token' do
        let(:token) { JwtService.new.json_response({ user: user }, (DateTime.now - 1.hour).to_i)[:access_token] }

        it 'returns true' do
          expect(user.send(:token_expired?, token)).to eq true
        end
      end

      context 'for valid token' do
        let(:token) { JwtService.new.json_response(user: user)[:access_token] }

        it 'returns false' do
          expect(user.send(:token_expired?, token)).to eq false
        end
      end
    end
  end
end
