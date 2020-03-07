# frozen_string_literal: true

# Form object for World model
class WorldDryForm < Dry::Struct
  # Default types
  module Types
    include Dry::Types(default: :nominal)
  end

  attribute :id, Types::Integer.optional
  attribute :name, Types::String
  attribute :zone, Types::Integer

  attr_reader :world, :errors

  def save
    attributes = to_hash
    schema = WorldContract.new.call(attributes)
    @errors = schema.errors(locale: I18n.locale).to_h.values.flatten
    return false unless errors.empty?
    @world = attributes[:id] ? World.find_by(id: attributes[:id]) : World.new
    world.attributes = attributes.except(:id)
    world.save
  end
end

# Validation class for World Form
class WorldContract < Dry::Validation::Contract
  config.messages.namespace = :world
  config.messages.backend = :i18n

  schema do
    optional(:id)
    required(:name).filled(:string)
    required(:zone).filled(:string)
  end

  rule(:id, :name, :zone) do
    worlds = values[:id].nil? ? World.all : World.where.not(id: values[:id])

    key.failure(I18n.t('dry_validation.errors.world.is_exist')) if worlds.where(name: values[:name], zone: values[:zone]).exists?
  end
end
