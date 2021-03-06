# frozen_string_literal: true

# Create delivery and delivery param
class CreateDeliveryWithParams
  include Interactor::Organizer

  organize CreateDelivery, CreateDeliveryParam
end
