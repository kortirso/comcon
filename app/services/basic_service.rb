# frozen_string_literal: true

module BasicService
  module ClassMethods
    def call(*args)
      new.call(*args)
    end
  end

  def self.prepended(base)
    base.extend ClassMethods
  end
end
