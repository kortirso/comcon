# frozen_string_literal: true

# Represents form object for Bank model
class BankForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :coins, Integer, default: 0
  attribute :guild, Guild

  validates :name, :coins, :guild, presence: true

  attr_reader :bank

  def persist?
    return false unless valid?

    @bank = id ? Bank.find_by(id: id) : Bank.new
    @bank.attributes = attributes.except(:id)
    @bank.save
    true
  end
end
