# frozen_string_literal: true

# Represents form object for Profession model
class ProfessionForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, Hash
  attribute :main, Boolean, default: true
  attribute :recipeable, Boolean, default: false

  validates :name, presence: true
  validate :name_as_hash

  attr_reader :profession

  def persist?
    return false unless valid?
    return false if exists?

    @profession = Profession.new
    @profession.attributes = attributes
    @profession.save
    true
  end

  private

  def exists?
    Profession.find_by(name: name).present?
  end

  def name_as_hash
    return errors.add(:name, message: 'Name is not hash') unless name.is_a?(Hash)

    errors.add(:name, message: 'Name EN is empty') if name['en'].blank?
    errors.add(:name, message: 'Name RU is empty') if name['ru'].blank?
  end
end
