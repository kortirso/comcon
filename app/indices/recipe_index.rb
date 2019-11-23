ThinkingSphinx::Index.define :recipe, with: :real_time do
  # indexes
  indexes name_ru, type: :string, as: :name_ru
  indexes name_en, type: :string, as: :name_en
  indexes effect_name_ru, type: :string, as: :effect_name_ru
  indexes effect_name_en, type: :string, as: :effect_name_en

  # attributes
  has profession_id, type: :integer

  # properties
  set_property min_infix_len: 3
end
