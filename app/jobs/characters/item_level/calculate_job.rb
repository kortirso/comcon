# frozen_string_literal: true

module Characters
  module ItemLevel
    class CalculateJob < ApplicationJob
      queue_as :default

      def perform
        ::Characters::ItemLevel::CalculateService.call
      end
    end
  end
end
