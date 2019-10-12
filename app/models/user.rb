# Represents users in the system
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  validates :role, presence: true, inclusion: { in: %w[user admin] }

  def is_admin?
    role == 'admin'
  end
end
