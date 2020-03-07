RSpec.describe Static, type: :model do
  it { should belong_to :staticable }
  it { should belong_to :fraction }
  it { should belong_to :world }
  it { should belong_to :world_fraction }
  it { should have_many(:static_members).dependent(:destroy) }
  it { should have_many(:characters).through(:static_members) }
  it { should have_many(:static_invites).dependent(:destroy) }
  it { should have_many(:invited_characters).through(:static_invites).source(:static) }
  it { should have_many(:subscribes).dependent(:destroy) }
  it { should have_many(:signed_subscribes).class_name('Subscribe') }
  it { should have_many(:signed_characters).through(:signed_subscribes).source(:character) }
  it { should have_one(:group_role).dependent(:destroy) }

  it 'factory should be valid' do
    static = create :static, :guild

    expect(static).to be_valid
  end

  describe '.time_offset_value' do
    context 'for guild static' do
      let!(:static) { create :static, :guild }
      let!(:time_offset) { create :time_offset, timeable: static.staticable }

      it 'returns time_offset value of guild' do
        expect(static.time_offset_value).to eq static.staticable.time_offset.value
      end
    end

    context 'for character static' do
      let!(:static) { create :static, :character }
      let!(:user) { static.staticable.user }
      let!(:time_offset) { create :time_offset, timeable: static.staticable.user, value: nil }

      context 'without value' do
        it 'returns locale of character user' do
          user.reload

          expect(static.time_offset_value).to eq 0
        end
      end

      context 'with value' do
        it 'returns locale of character user' do
          user.reload
          user.time_offset.update(value: 3)

          expect(static.time_offset_value).to eq user.time_offset.value
        end
      end
    end
  end

  describe '.locale' do
    context 'for guild static' do
      let!(:static) { create :static, :guild }

      it 'returns locale of guild' do
        expect(static.locale).to eq static.staticable.locale
      end
    end

    context 'for character static' do
      let!(:static) { create :static, :character }

      it 'returns locale of character world' do
        expect(static.locale).to eq static.staticable.world.locale
      end
    end
  end
end
