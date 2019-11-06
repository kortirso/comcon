# Module for deliveries
module DeliveryMethod
  # Delivery with Discord webhooks
  class DiscordWebhook
    def self.call(delivery_param:, content:)
      client = DiscordBot::Client.new(bot_token: ENV['DISCORD_BOT_TOKEN'])
      client.execute_webhook(webhook_id: delivery_param.params['id'], webhook_token: delivery_param.params['token'], content: content)
    end
  end
end
