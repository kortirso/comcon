RSpec.describe RecipeForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { RecipeForm.new(name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new recipe' do
        expect { service.persist? }.to_not change(Recipe, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:recipe) { create :recipe }

      context 'for existed recipe' do
        let(:service) { RecipeForm.new(name: recipe.name, profession: recipe.profession, links: { 'en' => '1', 'ru' => '1' }, skill: 1) }

        it 'does not create new recipe' do
          expect { service.persist? }.to_not change(Recipe, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted recipe' do
        let(:service) { RecipeForm.new(name: { 'en' => 'Plans: Sulfuron Hammer', 'ru' => 'Чертеж: сульфуронский молот' }, profession: recipe.profession, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1) }

        it 'creates new recipe' do
          expect { service.persist? }.to change { Recipe.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end

      context 'for invalid profession' do
        let!(:profession) { create :profession, recipeable: false }
        let(:service) { RecipeForm.new(name: { 'en' => 'Plans: Sulfuron Hammer', 'ru' => 'Чертеж: сульфуронский молот' }, profession: profession, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1) }

        it 'does not create new recipe' do
          expect { service.persist? }.to_not change(Recipe, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end
    end

    context 'for updating' do
      let!(:recipe) { create :recipe }
      let!(:other_recipe) { create :recipe }

      context 'for unexisted recipe' do
        let(:service) { RecipeForm.new(id: 999, name: { 'en' => 'Plans: Sulfuron Hammer', 'ru' => 'Чертеж: сульфуронский молот' }, profession: recipe.profession, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed recipe' do
        context 'for invalid data' do
          let(:service) { RecipeForm.new(recipe.attributes.merge(name: { 'en' => '', 'ru' => '' }, profession: recipe.profession, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1)) }

          it 'does not update recipe' do
            service.persist?
            recipe.reload

            expect(recipe.name).to_not eq('en' => '', 'ru' => '')
          end
        end

        context 'for existed data' do
          let(:service) { RecipeForm.new(recipe.attributes.merge(name: other_recipe.name, profession: other_recipe.profession, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1)) }

          it 'does not update recipe' do
            service.persist?
            recipe.reload

            expect(recipe.name).to_not eq other_recipe.name
          end
        end

        context 'for valid data' do
          let(:service) { RecipeForm.new(recipe.attributes.merge(name: { 'en' => 'Plans: Sulfuron Hammer', 'ru' => 'Чертеж: сульфуронский молот' }, profession: recipe.profession, links: { 'en' => 'https://classic.wowhead.com/item=18592', 'ru' => 'https://ru.classic.wowhead.com/item=18592' }, skill: 1)) }

          it 'updates recipe' do
            service.persist?
            recipe.reload

            expect(recipe.name).to eq('en' => 'Plans: Sulfuron Hammer', 'ru' => 'Чертеж: сульфуронский молот')
          end
        end
      end
    end
  end
end
