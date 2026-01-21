class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders
  has_one :latest_payments, -> { order(created_at: :desc) }, class_name: 'Payment'

  validates :name, presence: true

end