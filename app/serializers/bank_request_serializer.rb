# frozen_string_literal: true

class BankRequestSerializer < ActiveModel::Serializer
  attributes :id, :character_name, :bank_name, :game_item_name, :requested_amount

  def bank_name
    object.bank.name
  end

  def character_name
    object.character.name
  end

  def game_item_name
    object.game_item.name
  end
end
