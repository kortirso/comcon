module Providers
  # check user identity through discord
  class Discord
    include HTTParty

    base_uri 'https://discordapp.com/api/v6'
    format :json

    attr_reader :access_token, :user_agent

    def initialize(access_token:)
      @access_token = access_token
      @user_agent = 'GuildHall'
    end

    def call
      headers = { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{access_token}", 'User-Agent' => user_agent }
      self.class.get('/users/@me', query: {}, headers: headers).parsed_response
    end
  end
end
