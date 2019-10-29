require 'csv'

# Service for uploading recipes from csv file
class UploadRecipes
  def self.call
    professions = Profession.all.inject({}) { |profs, prof| profs.merge(prof.name['ru'] => prof) }
    CSV.foreach(path, col_sep: ',') do |row|
      recipe_form = RecipeForm.new(name: { 'en' => row[4], 'ru' => row[2] }, links: { 'en' => row[5], 'ru' => row[3] }, skill: row[1].to_i, profession: professions[row[0]])
      recipe_form.persist?
    end
  end

  def self.path
    "#{Rails.root}/spec/fixtures/recipes.csv"
  end
end
