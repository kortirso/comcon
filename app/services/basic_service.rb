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

  attr_reader :errors

  def initialize
    super
    @errors = []
  end

  def call(*args)
    super(*args)
    self
  end

  def success?
    !failure?
  end

  def failure?
    @errors.any?
  end

  private

  def fail!(messages)
    @errors += Array(messages)
    self
  end
end
