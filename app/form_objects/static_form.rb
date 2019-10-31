# Represents form object for Static model
class StaticForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :guild, Guild

  validates :name, :guild, presence: true
  validates :name, length: { in: 2..20 }

  attr_reader :static

  def persist?
    return false unless valid?
    return false if exists?
    @static = id ? Static.find_by(id: id) : Static.new
    return false if @static.nil?
    @static.attributes = attributes.except(:id)
    @static.save
    true
  end

  private

  def exists?
    statics = id.nil? ? Static.all : Static.where.not(id: id)
    statics.find_by(guild: guild, name: name).present?
  end
end
