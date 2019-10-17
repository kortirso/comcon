RSpec.describe JwtService, type: :service do
  let(:service) { JwtService.new }

  describe '.initialize' do
    it 'class JWT_TTL constant' do
      expect(JwtService::JWT_TTL).to_not eq nil
    end
  end

  describe '.json_response' do
    let!(:user) { create :user }
    let(:response) { service.json_response(user: user) }

    it 'returns access_token' do
      expect(response[:access_token]).to_not eq nil
      expect(response[:access_token].is_a?(String)).to eq true
    end

    it 'and returns user information' do
      expect(response[:user]).to_not eq nil
      expect(response[:user].is_a?(Hash)).to eq true
    end

    it 'and returns expiration information' do
      expect(response[:expires_at]).to_not eq nil
      expect(response[:expires_at].is_a?(Integer)).to eq true
    end
  end

  describe '.decode' do
    let!(:user) { create :user }
    let(:response) { service.json_response(user: user) }
    let(:decode) { service.decode(access_token: response[:access_token]) }

    it 'decodes information from token' do
      expect(decode).to_not eq nil
    end

    it 'it contains user_id' do
      expect(decode['user_id']).to eq user.id
    end

    it 'and it contains exp' do
      expect(decode['exp']).to_not eq nil
    end
  end

  describe '.encode' do
    let!(:user) { create :user }
    let(:encode) { service.send(:encode, user_id: user.id) }

    it 'returns array' do
      expect(encode.is_a?(Array)).to eq true
    end

    it 'it contains token' do
      expect(encode[0].is_a?(String)).to eq true
    end

    it 'and contains expiration time' do
      expect(encode[1].is_a?(Integer)).to eq true
    end
  end

  describe '.jwt_secret' do
    it 'returns secret key for app' do
      expect(service.send(:jwt_secret)).to eq Rails.application.secrets.secret_key_base
    end
  end
end
