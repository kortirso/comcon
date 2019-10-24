shared_examples_for 'API auth admins' do
  let!(:user) { create :user }
  let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
  before { do_request('Authorization' => access_token) }

  it 'returns status 400' do
    expect(response.status).to eq 400
  end

  it 'and contains error message' do
    expect(JSON.parse(response.body)).to eq('error' => 'Forbidden')
  end
end
