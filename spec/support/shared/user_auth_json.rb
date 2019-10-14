RSpec.shared_examples_for 'User Auth JSON' do
  context 'for unlogged users' do
    it 'renders json with error' do
      do_request

      expect(JSON.parse(response.body)).to eq('error' => 'You need to sign in or sign up before continuing.')
    end
  end
end
