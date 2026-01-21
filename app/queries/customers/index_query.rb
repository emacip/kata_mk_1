module Customers
  class IndexQuery
    def initialize(view:)
      @view = view
    end

    def call
      case @view
      when :with_payments
        Customer.includes(orders: :payments)
      when :with_latest_payment
        Customer.includes(latest_account: :order)
      else
        raise ArgumentError, "Unknown view: #{@view.inspect}"
      end
    end
  end
end
