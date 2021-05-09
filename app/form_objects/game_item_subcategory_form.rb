# frozen_string_literal: true

# Represents form object for GameItemSubcategory model
class GameItemSubcategoryForm
  include ActiveModel::Model
  include Virtus.model

  attribute :uid, Integer
  attribute :name, Hash

  validates :uid, :name, presence: true
  validate :name_as_hash

  attr_reader :game_item_subcategory

  def persist?
    return false unless valid?

    @game_item_subcategory = GameItemSubcategory.new
    @game_item_subcategory.attributes = attributes
    @game_item_subcategory.save
    true
  end

  private

  def name_as_hash
    return errors.add(:name, message: 'Name is not hash') unless name.is_a?(Hash)

    errors.add(:name, message: 'Name EN is empty') if name['en'].blank?
    errors.add(:name, message: 'Name RU is empty') if name['ru'].blank?
  end
end
