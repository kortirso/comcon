RSpec.describe UploadRecipes, type: :service do
  describe '.call' do
    let!(:profession) { create :profession, name: { 'en' => 'Alchemy', 'ru' => 'Алхимия' }, main: true, recipeable: true }
    let(:request) { UploadRecipes.call }

    it 'creates recipes for profession' do
      expect { request }.to change { profession.recipes.count }.by(23)
    end
  end
end
