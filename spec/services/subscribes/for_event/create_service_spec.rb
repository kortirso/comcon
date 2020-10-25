# frozen_string_literal: true

RSpec.describe Subscribes::ForEvent::CreateService, type: :service do
  subject(:service_call) { described_class.call(event: event) }

  describe 'for guild event' do
    let!(:guild) { create :guild }
    let!(:event) { create :event, eventable: guild }

    let!(:user1) { create :user }
    let!(:character1) { create :character, user: user1, guild: guild, main: false }
    let!(:character2) { create :character, user: user1, guild: guild, main: false }
    let!(:character3) { create :character, user: user1, guild: guild, main: true }
    let!(:user2) { create :user }
    let!(:character4) { create :character, user: user2, guild: guild, main: false }
    let!(:user3) { create :user }
    let!(:character5) { create :character, user: user3, guild: guild, main: false, level: 59 }
    let!(:character6) { create :character, user: user3, guild: guild, main: false, level: 60 }

    it 'creates 4 subscribes' do
      expect { service_call }.to change { Subscribe.count }.by(4)
    end

    it 'and this subscribes is for mains and high levels', :aggregate_failures do
      service_call

      character_ids = Subscribe.all.pluck(:character_id)

      expect(character_ids.include?(character1.id)).to eq false
      expect(character_ids.include?(character2.id)).to eq false
      expect(character_ids.include?(character3.id)).to eq true
      expect(character_ids.include?(character4.id)).to eq true
      expect(character_ids.include?(character5.id)).to eq false
      expect(character_ids.include?(character6.id)).to eq true
    end
  end
end
