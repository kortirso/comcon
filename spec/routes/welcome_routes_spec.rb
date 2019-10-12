RSpec.describe WelcomeController, type: :routing do
  describe 'invalid routing' do
    it 'route to route_error path' do
      expect(get: '/welcome/indexer').to route_to(
        controller: 'application',
        action: 'catch_route_error',
        path: 'welcome/indexer'
      )
    end
  end

  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/').to route_to('welcome#index', locale: 'en')
    end
  end
end
