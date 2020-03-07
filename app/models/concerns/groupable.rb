# frozen_string_literal: true

# Represents relationships between group_roles and others
module Groupable
  extend ActiveSupport::Concern

  included do
    has_one :group_role, as: :groupable, dependent: :destroy
  end
end
