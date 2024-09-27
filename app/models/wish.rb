class Wish < ApplicationRecord

  has_many :likes, dependent: :destroy
end
