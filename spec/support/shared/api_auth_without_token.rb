# frozen_string_literal: true

shared_examples_for 'API auth without token' do
  before { do_request }

  it 'returns status 401' do
    expect(response.status).to eq 401
  end

  it 'and contains error message' do
    expect(JSON.parse(response.body)).to eq('errors' => 'There is no authorization token')
  end
end
