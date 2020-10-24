# frozen_string_literal: true

# Represents form object for Dungeon model
class DungeonForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :raid, Boolean, default: false

  validates :name, presence: true

  attr_reader :dungeon

  def persist?
    return false unless valid?
    return false if exists?

    @dungeon = id ? Dungeon.find_by(id: id) : Dungeon.new
    return false if @dungeon.nil?

    @dungeon.attributes = attributes.except(:id)
    @dungeon.save
    true
  end

  private

  def exists?
    dungeons = id.nil? ? Dungeon.all : Dungeon.where.not(id: id)
    dungeons.find_by(name: name).present?
  end
end
