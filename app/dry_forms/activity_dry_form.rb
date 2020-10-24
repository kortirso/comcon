# frozen_string_literal: true

# Form object for Activity model
class ActivityDryForm < Dry::Struct
  # Default types
  module Types
    include Dry::Types(default: :nominal)
    Guild = Dry::Types::Nominal.new(::Guild)
  end

  attribute :id, Types::Integer.optional
  attribute :title, Types::String
  attribute :description, Types::String
  attribute :guild, Types::Guild

  attr_reader :activity, :errors

  def save
    attributes = to_hash
    schema = ActivityContract.new.call(attributes)
    @errors = schema.errors(locale: I18n.locale).to_h.values.flatten
    return false unless errors.empty?

    @activity = attributes[:id] ? Activity.find_by(id: attributes[:id]) : Activity.new
    activity.attributes = attributes.except(:id)
    activity.save
  end
end

# Validation class for Activity Form
class ActivityContract < Dry::Validation::Contract
  config.messages.namespace = :activity
  config.messages.backend = :i18n

  schema do
    optional(:id)
    required(:title).filled(:string)
    required(:description).filled(:string)
    required(:guild).filled
  end
end
