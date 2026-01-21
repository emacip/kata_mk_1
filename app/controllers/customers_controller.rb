class CustomersController < ApplicationController
  def index
    view = :with_latest_payment
    customers = Customers::IndexQuery.new(view: view).call
    render json: customers.map { |customer| CustomerSerializer.new(customer, view: view).as_json }, status: :ok
  end
end