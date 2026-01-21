class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders

  validates :name, presence: true

end