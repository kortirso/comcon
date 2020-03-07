# frozen_string_literal: true

# Create Realm and WorldFractions
class CreateRealm
  include Interactor::Organizer

  organize CreateWorld, CreateWorldFractions
end
