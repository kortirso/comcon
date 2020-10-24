# frozen_string_literal: true

# Represents form object for Fraction model
class FractionForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, Hash

  validates :name, presence: true
  validate :name_as_hash

  attr_reader :fraction

  def persist?
    return false unless valid?
    return false if exists?

    @fraction = Fraction.new
    @fraction.attributes = attributes
    @fraction.save
    true
  end

  private

  def exists?
    Fraction.find_by(name: name).present?
  end

  def name_as_hash
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)

    errors[:name] << 'Name EN is empty' if name['en'].blank?
    errors[:name] << 'Name RU is empty' if name['ru'].blank?
  end
end
