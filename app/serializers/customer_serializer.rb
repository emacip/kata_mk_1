class CustomerSerializer
  def initialize(customer, view:)
    @customer = customer
    @view = view
  end

  def as_json(*)
    case @view
    when :with_payments
      {
        "name" => @customer.name,
        "orders" => @customer.orders.map do |order|
          {
            "payments" => order.payments.map do |payment|{
              provider: payment.provider,
              status: payment.status
            }
            end

          }
        end
      }

    when :with_latest_payment
      {

      }
    else
      raise ArgumentError, "Unknown serializer view: #{@view.inspect}"
    end
  end
end