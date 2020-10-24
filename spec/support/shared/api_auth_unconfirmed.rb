# frozen_string_literal: true

shared_examples_for 'API auth unconfirmed' do
  let!(:user) { create :user, :unconfirmed }
  let(:access_token) { JwtService.new.json_response(user: user)[:access_token] }
  before { do_request('Authorization' => access_token) }

  it 'returns status 401' do
    expect(response.status).to eq 401
  end

  it 'and contains error message' do
    expect(JSON.parse(response.body)).to eq('errors' => 'Your email is not confirmed')
  end
end
