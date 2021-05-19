# frozen_string_literal: true

# Represents form object for Recipe model
class RecipeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :profession, Profession
  attribute :name, Hash
  attribute :links, Hash
  attribute :effect_name, Hash, default: { 'en' => '', 'ru' => '' }
  attribute :effect_links, Hash, default: { 'en' => '', 'ru' => '' }
  attribute :skill, Integer

  validates :profession, :name, :links, :skill, :effect_name, :effect_links, presence: true
  validates :skill, inclusion: 1..375
  validate :exists?
  validate :name_as_hash
  validate :links_as_hash
  validate :effect_name_as_hash
  validate :effect_links_as_hash
  validate :profession_with_recipes

  attr_reader :recipe

  def persist?
    return false unless valid?

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
    return unless recipes.exists?(name: name)

    errors.add(:recipe, message: I18n.t('activemodel.errors.models.recipe_form.attributes.recipe.already_exist'))
  end

  def name_as_hash
    return errors.add(:name, message: I18n.t('activemodel.errors.models.recipe_form.attributes.name.is_not_hash')) unless name.is_a?(Hash)

    errors.add(:name, message: I18n.t('activemodel.errors.models.recipe_form.attributes.name.en_is_empty')) if name['en'].blank?
    errors.add(:name, message: I18n.t('activemodel.errors.models.recipe_form.attributes.name.ru_is_empty')) if name['ru'].blank?
  end

  def links_as_hash
    return errors.add(:links, message: I18n.t('activemodel.errors.models.recipe_form.attributes.links.is_not_hash')) unless links.is_a?(Hash)

    errors.add(:links, message: I18n.t('activemodel.errors.models.recipe_form.attributes.links.en_is_empty')) if links['en'].blank?
    errors.add(:links, message: I18n.t('activemodel.errors.models.recipe_form.attributes.links.ru_is_empty')) if links['ru'].blank?
  end

  def effect_name_as_hash
    errors.add(:effect_name, message: I18n.t('activemodel.errors.models.recipe_form.attributes.effect_name.is_not_hash')) unless effect_name.is_a?(Hash)
  end

  def effect_links_as_hash
    errors.add(:effect_links, message: I18n.t('activemodel.errors.models.recipe_form.attributes.effect_links.is_not_hash')) unless effect_links.is_a?(Hash)
  end

  def profession_with_recipes
    return if profession.nil?
    return if profession.recipeable?

    errors.add(:profession, message: I18n.t('activemodel.errors.models.recipe_form.attributes.profession.is_not_recipeable'))
  end
end
