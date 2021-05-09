# frozen_string_literal: true

# Represents form object for GameItem model
class GameItemForm
  include ActiveModel::Model
  include Virtus.model

  attribute :item_uid, Integer
  attribute :level, Integer
  attribute :icon_name, String
  attribute :name, Hash
  attribute :game_item_quality, GameItemQuality
  attribute :game_item_category, GameItemCategory
  attribute :game_item_subcategory, GameItemSubcategory

  validates :item_uid, :level, :icon_name, :game_item_quality, presence: true
  validate :name_as_hash

  attr_reader :game_item

  def persist?
    return false unless valid?

    @game_item = GameItem.new
    @game_item.attributes = attributes
    @game_item.save
    true
  end

  private

  def name_as_hash
    return errors.add(:name, message: 'Name is not hash') unless name.is_a?(Hash)

    errors.add(:name, message: 'Name EN is empty') if name['en'].blank?
    errors.add(:name, message: 'Name RU is empty') if name['ru'].blank?
  end
end
