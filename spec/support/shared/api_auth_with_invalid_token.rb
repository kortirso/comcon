shared_examples_for 'API auth with invalid token' do
  let!(:user) { create :user }
  let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
  before { do_request('Authorization' => "#{access_token}1") }

  it 'returns status 401' do
    expect(response.status).to eq 401
  end

  it 'and contains error message' do
    expect(JSON.parse(response.body)).to eq('errors' => 'Signature verification error')
  end
end
