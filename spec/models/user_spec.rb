RSpec.describe User, type: :model do
  it { should have_many(:characters).dependent(:destroy) }
  it { should have_many(:guilds).through(:characters) }
  it { should have_many(:subscribes).through(:characters) }
  it { should have_many(:worlds).through(:characters) }
  it { should have_many(:static_members).through(:characters) }
  it { should have_many(:world_fractions).through(:characters) }
  it { should have_many(:identities).dependent(:destroy) }
  it { should have_one(:time_offset).dependent(:destroy) }
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_presence_of :role }
  it { should validate_inclusion_of(:role).in_array(%w[user admin]) }

  it 'factory should be valid' do
    user = build :user

    expect(user).to be_valid
  end

  it 'should be invalid without email' do
    user = User.new(email: nil)
    user.valid?

    expect(user.errors[:email]).to_not eq nil
  end

  it 'should be invalid without password' do
    user = User.new(password: nil)
    user.valid?

    expect(user.errors[:password]).to_not eq nil
  end

  it 'should be invalid with a duplicate email' do
    User.create(email: 'example@gmail.com', password: 'password12')
    user = User.new(email: 'example@gmail.com', password: 'password12')
    user.valid?

    expect(user.errors[:email]).to_not eq nil
  end

  describe 'methods' do
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

    context '.is_admin?' do
      it 'returns false for user' do
        user = create :user

        expect(user.is_admin?).to eq false
      end

      it 'returns true for admin' do
        user = create :user, :admin

        expect(user.is_admin?).to eq true
      end
    end

    context '.any_role?' do
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

    context '.any_character_in_static?' do
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

    context '.statics' do
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

    context '.remember' do
      let!(:user) { create :user }

      it 'updates remember_digest param from nil' do
        expect { user.remember }.to change(user, :remember_digest).from(nil)
      end
    end

    context '.forget' do
      let!(:user) { create :user }
      before { user.remember }

      it 'updates remember_digest param to nil' do
        expect { user.forget }.to change(user, :remember_digest).to(nil)
      end
    end

    context '.authenticated?' do
      let!(:user) { create :user, remember_digest: nil }

      it 'returns false for nil remember_digest' do
        expect(user.authenticated?('')).to eq false
      end

      it 'returns false for wrong digest/token' do
        token = SecureRandom.urlsafe_base64
        user.update_attribute(:remember_digest, User.digest(token))

        expect(user.authenticated?(token + '1')).to eq false
      end

      it 'returns true for correct digest' do
        token = SecureRandom.urlsafe_base64
        user.update_attribute(:remember_digest, User.digest(token))

        expect(user.authenticated?(token)).to eq true
      end
    end
  end
end
