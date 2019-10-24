# Represents form object for Recipe model
class RecipeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :profession, Profession
  attribute :name, Hash
  attribute :links, Hash
  attribute :skill, Integer

  validates :profession, :name, :links, :skill, presence: true
  validates :skill, inclusion: 1..300
  validate :name_as_hash
  validate :links_as_hash

  attr_reader :recipe

  def persist?
    return false unless valid?
    return false if exists?
    @recipe = id ? Recipe.find_by(id: id) : Recipe.new
    return false if @recipe.nil?
    @recipe.attributes = attributes.except(:id)
    @recipe.save
    true
  end

  private

  def exists?
    return if profession.nil?
    recipes = id.nil? ? profession.recipes : profession.recipes.where.not(id: id)
    recipes.find_by(name: name).present?
  end

  def name_as_hash
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)
    errors[:name] << 'Name EN is empty' unless name['en'].present?
    errors[:name] << 'Name RU is empty' unless name['ru'].present?
  end

  def links_as_hash
    return errors[:links] << 'Links is not hash' unless links.is_a?(Hash)
    errors[:links] << 'Links EN is empty' unless links['en'].present?
    errors[:links] << 'Links RU is empty' unless links['ru'].present?
  end
end
