# Check user identity at providers
class CheckProvider
  attr_reader :provider, :access_token

  def initialize(provider:, access_token:)
    @provider = provider
    @access_token = access_token
  end

  def call
    case provider
      when 'discord' then Providers::Discord.new(access_token: access_token).call
    end
  end
end
