# frozen_string_literal: true

# Delivery content by discord
class PerformDelivery
  def self.call(delivery:, content:)
    case delivery.delivery_type
    when 'discord_webhook' then DiscordMethod::ExecuteWebhook.call(delivery_param: delivery.delivery_param, content: content)
    when 'discord_message' then DiscordMethod::CreateChannelMessage.call(delivery_param: delivery.delivery_param, content: content)
    end
  rescue
    false
  end
end
