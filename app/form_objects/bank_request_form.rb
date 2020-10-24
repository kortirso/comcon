# frozen_string_literal: true

# Represents form object for BankRequest model
class BankRequestForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :bank, Bank
  attribute :game_item, GameItem
  attribute :character, Character
  attribute :requested_amount, Integer
  attribute :provided_amount, Integer, default: 0
  attribute :character_name, String
  attribute :status, Integer, default: 0

  validates :bank, :game_item, :character, :requested_amount, :status, presence: true
  validates :status, inclusion: 0..2
  validate :status_value
  validate :left_amount

  attr_reader :bank_request

  def persist?
    return false unless valid?

    self.character_name = character.name
    @bank_request = BankRequest.new
    @bank_request.attributes = attributes
    @bank_request.save
    true
  end

  private

  def status_value
    return if status.zero?

    errors[:status] << 'not valid'
  end

  def left_amount
    bank_cell = BankCell.find_by(bank: bank, game_item: game_item)
    return errors[:bank] << 'does not have requested item' if bank_cell.nil?

    errors[:bank] << 'does not have requested amount of items' if bank_cell.amount < requested_amount
  end
end
