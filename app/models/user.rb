# Represents users in the system
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable
end
