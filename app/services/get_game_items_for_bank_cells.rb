# frozen_string_literal: true

# upload game items
class GetGameItemsForBankCells
  attr_reader :item_uids, :equipment_uids

  def initialize
    @item_uids = BankCell.empty.pluck(:item_uid).uniq
    @equipment_uids = Equipment.empty.pluck(:item_uid).uniq
  end

  def call
    item_uids.each.with_index do |item_uid, index|
      next if index.positive? && Rails.env.test?

      game_item = perform(item_uid: item_uid)
      next if game_item.nil?

      BankCell.where(item_uid: item_uid).update_all(game_item_id: game_item.id)
    end
    equipment_uids.each.with_index do |item_uid, index|
      next if index.positive? && Rails.env.test?

      game_item = perform(item_uid: item_uid)
      next if game_item.nil?

      Equipment.where(item_uid: item_uid).update_all(game_item_id: game_item.id)
    end
  end

  private

  def perform(item_uid:)
    game_item_quality_params = { uid: nil, name: { 'en' => '', 'ru' => '' } }
    game_item_category_params = { uid: nil, name: { 'en' => '', 'ru' => '' } }
    game_item_subcategory_params = { uid: nil, name: { 'en' => '', 'ru' => '' } }
    game_item_params = { item_uid: item_uid, name: { 'en' => '', 'ru' => '' }, level: nil, icon_name: '' }

    %w[en ru].each do |locale|
      prefix = locale == 'en' ? '' : 'ru.'

      response = HTTParty.get("https://#{prefix}tbc.wowhead.com/item=#{item_uid}&xml", format: :plain)
      doc = Nokogiri::XML(response.parsed_response)

      game_item_category_params[:name][locale] = doc.xpath('//wowhead//item//class').children.text
      game_item_subcategory_params[:name][locale] = doc.xpath('//wowhead//item//subclass').children.text
      game_item_params[:name][locale] = doc.xpath('//wowhead//item//name').text
      game_item_quality_params[:name][locale] = doc.xpath('//wowhead//item//quality').text

      sleep(1)
      next if locale == 'ru'

      game_item_category_params[:uid] = doc.xpath('//wowhead//item//class')[0].attributes['id'].text.to_i
      game_item_subcategory_params[:uid] = doc.xpath('//wowhead//item//subclass')[0].attributes['id'].text.to_i
      game_item_quality_params[:uid] = doc.xpath('//wowhead//item//quality')[0].attributes['id'].text.to_i
      game_item_params[:level] = doc.xpath('//wowhead//item//level').text
      game_item_params[:icon_name] = doc.xpath('//wowhead//item//icon').text
    end

    game_item_quality = find_object(params: game_item_quality_params, object_type: 'game_item_quality', object_class: GameItemQuality, object_form_class: GameItemQualityForm)
    game_item_category = find_object(params: game_item_category_params, object_type: 'game_item_category', object_class: GameItemCategory, object_form_class: GameItemCategoryForm)
    game_item_subcategory = find_object(params: game_item_subcategory_params, object_type: 'game_item_subcategory', object_class: GameItemSubcategory, object_form_class: GameItemSubcategoryForm)

    game_item_params = game_item_params.merge(game_item_quality: game_item_quality, game_item_category: game_item_category, game_item_subcategory: game_item_subcategory)
    find_game_item(params: game_item_params)
  rescue URI::InvalidURIError, NoMethodError => _e
    nil
  end

  def find_object(params:, object_type:, object_class:, object_form_class:)
    object = object_class.find_by(uid: params[:uid], name: params[:name])
    return object unless object.nil?

    object_form = object_form_class.new(params)
    object = object_form[object_type] if object_form.persist?
    object
  end

  def find_game_item(params:)
    object = GameItem.find_by(item_uid: params[:item_uid])
    return object unless object.nil?

    object_form = GameItemForm.new(params)
    object = object_form.game_item if object_form.persist?
    object
  end
end
