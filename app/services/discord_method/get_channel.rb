# Module for deliveries
module DiscordMethod
  # Gen channel info
  class GetChannel
    def self.call(channel_id:)
      client = DiscordBot::Client.new(bot_token: ENV['DISCORD_BOT_TOKEN'])
      client.get_channel(channel_id: channel_id)
    end
  end
end
