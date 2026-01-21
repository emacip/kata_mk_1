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
        latest_payments_sql = Payment
                                .joins(:order)
                                .select(
                                  "DISTINCT ON (orders.customer_id) " \
                                    "orders.customer_id AS customer_id, " \
                                    "payments.provider AS provider, " \
                                    "payments.status AS status"
                                )
                                .order("orders.customer_id, payments.created_at DESC, payments.id DESC")
                                .to_sql
        Customer
          .joins("LEFT JOIN (#{latest_payments_sql}) latest_payments ON latest_payments.customer_id = customers.id")
          .select(
            "customers.id",
            "customers.name",
            "latest_payments.provider AS latest_payment_provider",
            "latest_payments.status AS latest_payment_status"
          )


      else
        raise ArgumentError, "Unknown view: #{@view.inspect}"
      end
    end
  end
end
