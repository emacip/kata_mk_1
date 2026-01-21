class Order < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :payments, through: :customers

end