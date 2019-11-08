require 'bcrypt'

# Add token/hash generating for user/guest models for sessions
module Personable
  extend ActiveSupport::Concern

  attr_accessor :remember_token

  def self.included(base)
    base.extend(ClassMethods)
  end

  # Class methods for personable
  module ClassMethods
    # Returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Remembers a person's token in the database for use in persistent sessions.
  def remember
    self.remember_token = self.class.new_token
    update_attribute(:remember_digest, self.class.digest(remember_token))
  end

  # Forget a person in the database for use in persistent sessions.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
