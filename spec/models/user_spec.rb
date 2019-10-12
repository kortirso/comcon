RSpec.describe User, type: :model do
  it { should have_many(:characters).dependent(:destroy) }
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

    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'should be invalid without password' do
    user = User.new(password: nil)
    user.valid?

    expect(user.errors[:password]).to include("can't be blank")
  end

  it 'should be invalid with a duplicate email' do
    User.create(email: 'example@gmail.com', password: 'password12')
    user = User.new(email: 'example@gmail.com', password: 'password12')
    user.valid?

    expect(user.errors[:email]).to include('has already been taken')
  end

  describe 'methods' do
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
  end
end
