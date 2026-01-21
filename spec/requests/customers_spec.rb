require "rails_helper"

RSpec.describe "Customers", type: :request do
  describe "GET /index" do
    describe "feature behaviour" do
      let(:customer) { Customer.create!(name: Faker::Name.name) }
      let(:order)    { Order.create!(customer: customer) }
      let!(:payment) do
        Payment.create!(order: order, provider: "stripe", status: "paid")
      end

      it "returns http success", :stage_1, :customer_with_order_payment do
        get customers_path
        expect(response).to have_http_status(:success)
      end

      it "renders a JSON response", :stage_1, :customer_with_order_payment do
        get customers_path
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end

      it "renders customers and their associated orders and payments", :stage_1, :customer_with_order_payment do
        get customers_path

        expect(response.parsed_body).to contain_exactly(
                                          {
                                            "name" => customer.name,
                                            "orders" => [
                                              {
                                                "payments" => [
                                                  {
                                                    "provider" => payment.provider,
                                                    "status" => payment.status
                                                  }
                                                ]
                                              }
                                            ]
                                          }
                                        )
      end

      it "returns customers and their latest payment", :stage_2, :customer_with_order_payment do
        get customers_path

        expect(response.parsed_body).to contain_exactly(
                                          {
                                            "name" => customer.name,
                                            "latest_payment" => {
                                              "provider" => payment.provider,
                                              "status" => payment.status
                                            }
                                          }
                                        )
      end
    end

    describe "performance tests" do
      describe "N+1", :n_plus_one do
        populate do |n|
          n.times do
            customer = Customer.create!(name: Faker::Name.name)
            order    = Order.create!(customer: customer)
            Payment.create!(order: order, provider: "stripe", status: "paid")
          end
        end

        it "eager loads associations", :stage_1, :stage_2 do
          expect { get customers_path }.to perform_constant_number_of_queries
        end
      end

      it "performs the request under 150 ms", :stage_1 do
        customer_ids = Customer.insert_all(
          100.times.map { { name: Faker::Name.name } },
          returning: :id
        ).rows.flatten

        order_ids = Order.insert_all(
          1000.times.map { { customer_id: customer_ids.sample } },
          returning: :id
        ).rows.flatten

        Payment.insert_all(
          3000.times.map do
            {
              order_id:  order_ids.sample,
              provider:  "stripe",
              status:    "paid",
              created_at: Time.current,
              updated_at: Time.current
            }
          end
        )

        expect { get customers_path }.to perform_under(150).ms.warmup(2).times.sample(10).times
        expect(response).to have_http_status(:success)
      end

      it "performs the request under 150 ms", :stage_2 do
        customer_ids = Customer.insert_all(
          100.times.map { { name: Faker::Name.name } },
          returning: :id
        ).rows.flatten

        order_ids = Order.insert_all(
          2000.times.map { { customer_id: customer_ids.sample } },
          returning: :id
        ).rows.flatten

        # Heavy payments dataset: forces "latest payment per customer" efficiency
        Payment.insert_all(
          20_000.times.map do
            {
              order_id:  order_ids.sample,
              provider:  ["stripe", "adyen", "paypal"].sample,
              status:    ["paid", "failed", "pending"].sample,
              created_at: Time.current,
              updated_at: Time.current
            }
          end
        )

        expect { get customers_path }.to perform_under(150).ms.warmup(2).times.sample(10).times
        expect(response).to have_http_status(:success)
      end
    end
  end
end
