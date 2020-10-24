# frozen_string_literal: true

# Represents form object for Combination model
class CombinationForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :character_class, CharacterClass
  attribute :combinateable_id, Integer
  attribute :combinateable_type, String

  validates :character_class, :combinateable_id, :combinateable_type, presence: true
  validates :combinateable_type, inclusion: { in: %w[Role Race] }

  attr_reader :combination

  def persist?
    return false unless valid?
    return false unless combinateable_exists?

    @combination = id ? Combination.find_by(id: id) : Combination.new
    return false if @combination.nil?

    @combination.attributes = attributes.except(:id)
    @combination.save
    true
  end

  private

  def combinateable_exists?
    combinateable_type.constantize.find_by(id: combinateable_id).present?
  end
end
