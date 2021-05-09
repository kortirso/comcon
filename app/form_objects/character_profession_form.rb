# frozen_string_literal: true

# Represents form object for CharacterProfession model
class CharacterProfessionForm
  include ActiveModel::Model
  include Virtus.model

  attribute :character, Character
  attribute :profession, Profession

  validates :character, :profession, presence: true
  validate :only_two_main_professions

  attr_reader :character_profession

  def persist?
    return false unless valid?
    return false if exists?

    @character_profession = CharacterProfession.new
    @character_profession.attributes = attributes.except(:id)
    @character_profession.save
    true
  end

  private

  def exists?
    CharacterProfession.find_by(character: character, profession: profession).present?
  end

  def only_two_main_professions
    return if character.nil?
    return if character.professions.where(main: true).size <= 1 || !profession.main?

    errors.add(:count, message: 'is reached limit')
  end
end
