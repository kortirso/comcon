# frozen_string_literal: true

# Calculate item level for new equipment
class CalcItemLevelForCharactersJob < ApplicationJob
  queue_as :default

  def perform
    CalcItemLevelForCharacters.new.call
  end
end
