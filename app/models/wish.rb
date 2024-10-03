class Wish < ApplicationRecord
  validates :title, presence: true
  has_many :likes, dependent: :destroy
end
