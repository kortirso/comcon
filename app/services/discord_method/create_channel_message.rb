# frozen_string_literal: true

# Module for deliveries
module DiscordMethod
  # Send message to channel
  class CreateChannelMessage
    def self.call(delivery_param:, content:)
      client = DiscordBot::Client.new(bot_token: ENV['DISCORD_BOT_TOKEN'])
      client.create_channel_message(channel_id: DiscordChannelCheck.call(delivery_param: delivery_param), content: content)
    end
  end
end
