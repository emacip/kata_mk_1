class Payment < ApplicationRecord
  belongs_to :order
  has_one :customer, through: :order

  validates :provider, :status, presence: true

end