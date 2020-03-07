# frozen_string_literal: true

module Api
  module V1
    class CharacterClassesController < Api::V1::BaseController
      before_action :find_character_classes, only: %i[index]

      resource_description do
        short 'CharacterClass resources'
        formats ['json']
      end

      api :GET, '/v1/character_classes.json', 'Get list of character classes'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: @character_classes, status: :ok
      end

      private

      def find_character_classes
        @character_classes = CharacterClass.order(id: :asc)
      end
    end
  end
end
