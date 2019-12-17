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
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)
    errors[:name] << 'Name EN is empty' unless name['en'].present?
    errors[:name] << 'Name RU is empty' unless name['ru'].present?
  end
end
