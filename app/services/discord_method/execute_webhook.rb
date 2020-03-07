# frozen_string_literal: true

# Module for deliveries
module DiscordMethod
  # Send message with webhook
  class ExecuteWebhook
    def self.call(delivery_param:, content:)
      client = DiscordBot::Client.new(bot_token: ENV['DISCORD_BOT_TOKEN'])
      client.execute_webhook(webhook_id: delivery_param.params['id'], webhook_token: delivery_param.params['token'], content: content)
    end
  end
end
