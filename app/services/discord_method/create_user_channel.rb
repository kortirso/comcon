# frozen_string_literal: true

# Module for deliveries
module DiscordMethod
  # Create PM channel with user
  class CreateUserChannel
    def self.call(recipient_id:)
      client = DiscordBot::Client.new(bot_token: ENV['DISCORD_BOT_TOKEN'])
      client.create_user_channel(recipient_id: recipient_id)
    end
  end
end
