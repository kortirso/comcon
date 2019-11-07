# Macros for testing omniauth controllers
module OmniauthMacros
  def discord_hash
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(
      'provider' => 'discord',
      'uid' => '123545',
      'info' => {
        'email' => 'example_discord@xyze.it',
        'name' => 'Alberto Pellizzon',
        'first_name' => 'Alberto',
        'last_name' => 'Pellizzon',
        'image' => ''
      },
      'extra' => {
        'raw_info' => {}
      }
    )
  end

  def facebook_invalid_hash
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(
      'provider' => 'discord',
      'uid' => '123545',
      'info' => {
        'name' => 'Alberto Pellizzon',
        'first_name' => 'Alberto',
        'last_name' => 'Pellizzon',
        'image' => ''
      },
      'extra' => {
        'raw_info' => {}
      }
    )
  end
end
