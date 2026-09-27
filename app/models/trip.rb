class Trip < ApplicationRecord
  validates :name, presence: true
  validates :starting_location, presence: true
end
