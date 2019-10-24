class AddRecipeableToProfessions < ActiveRecord::Migration[5.2]
  def change
    add_column :professions, :recipeable, :boolean, null: false, default: false

    leatherworking = Profession.find_by(name: { 'en' => 'Leatherworking', 'ru' => 'Кожевничество' })
    alchemy = Profession.find_by(name: { 'en' => 'Alchemy', 'ru' => 'Алхимия' })
    blacksmithing = Profession.find_by(name: { 'en' => 'Blacksmithing', 'ru' => 'Кузнечное дело' })
    engineering = Profession.find_by(name: { 'en' => 'Engineering', 'ru' => 'Инженерное дело' })
    tailoring = Profession.find_by(name: { 'en' => 'Tailoring', 'ru' => 'Портняжное дело' })
    enchanting = Profession.find_by(name: { 'en' => 'Enchanting', 'ru' => 'Наложение чар' })
    cooking = Profession.find_by(name: { 'en' => 'Cooking', 'ru' => 'Кулинария' })

    [leatherworking, alchemy, blacksmithing, engineering, tailoring, enchanting, cooking].each do |profession|
      profession.update(recipeable: true)
    end
  end
end
