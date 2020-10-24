# frozen_string_literal: true

# Check channel existeness at discord
class DiscordChannelCheck
  attr_reader :delivery_param, :channel_id_value

  def self.call(delivery_param:)
    new(delivery_param: delivery_param).call
  end

  def initialize(delivery_param:)
    @delivery_param = delivery_param
    @channel_id_value = delivery_param.params['channel_id']
  end

  def call
    case delivery_param.delivery.deliveriable_type
    when 'Guild' then channel_id_value
    when 'User' then check_user_channel
    end
  end

  private

  def check_user_channel
    return check_discord_channel if channel_id_value.present?

    create_discord_channel
  end

  def check_discord_channel
    channel_id = DiscordMethod::GetChannel.call(channel_id: channel_id_value.to_i)['id']
    return create_discord_channel if channel_id.nil?

    channel_id
  end

  def create_discord_channel
    channel_id = DiscordMethod::CreateUserChannel.call(recipient_id: delivery_param.delivery.deliveriable.identities.find_by(provider: 'discord').uid.to_i)['id']
    return nil if channel_id.nil?

    delivery_param.update(params: { 'channel_id' => channel_id })
    channel_id
  end
end
