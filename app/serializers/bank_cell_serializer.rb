class BankCellSerializer < ActiveModel::Serializer
  attributes :id, :amount, :item_uid, :game_item

  def game_item
    return nil if object.game_item.nil?
    {
      name: object.game_item.name,
      level: object.game_item.level,
      icon_name: object.game_item.icon_name,
      quality: object.game_item.game_item_quality.name,
      category: object.game_item.game_item_category.name,
      subcategory: object.game_item.game_item_subcategory.name
    }
  end
end
