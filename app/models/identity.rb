# frozen_string_literal: true

# Represents identities of users for oauth
class Identity < ApplicationRecord
  belongs_to :user

  def self.find_for_oauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end
end
