shared_examples_for 'API auth with invalid token' do
  let!(:user) { create :user }
  let(:token) { JwtService.new.json_response(user: user)[:token] }
  before { do_request('Authorization' => "#{token}1") }

  it 'returns status 401' do
    expect(response.status).to eq 401
  end

  it 'and contains error message' do
    expect(JSON.parse(response.body)).to eq('errors' => 'Signature verification error')
  end
end
