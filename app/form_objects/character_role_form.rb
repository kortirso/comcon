# frozen_string_literal: true

# Represents form object for CharacterClass model
class CharacterRoleForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :character, Character
  attribute :role, Role
  attribute :main, Boolean, default: false

  validates :character, :role, presence: true
  validate :role_class_restrictions

  attr_reader :character_role

  def persist?
    return false unless valid?
    return false if exists?

    @character_role = id ? CharacterRole.find_by(id: id) : CharacterRole.new
    return false if @character_role.nil?

    @character_role.attributes = attributes.except(:id)
    @character_role.save
    true
  end

  private

  def exists?
    character_roles = id.nil? ? CharacterRole.all : CharacterRole.where.not(id: id)
    character_roles.find_by(character: character, role: role).present?
  end

  def role_class_restrictions
    return if role.nil?
    return if character.nil?
    return if Combination.find_by(character_class: character.character_class, combinateable: role).present?

    errors[:role] << 'is not valid for character class'
  end
end
