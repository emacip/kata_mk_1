class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders

  validates :name, presence: true


  def latest_payment
    payments.order(created_at: :desc, id: :desc).first
  end
end