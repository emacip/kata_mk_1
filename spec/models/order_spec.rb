require "rails_helper"

RSpec.describe Order, :stage_1 do
  describe "associations" do
    it "belongs to a customer" do
      customer = Customer.create!(name: Faker::Name.name)
      order = described_class.new(customer: customer)

      expect(order.customer).to eq(customer)
    end

    it "has many payments" do
      customer = Customer.create!(name: Faker::Name.name)
      order = described_class.create!(customer: customer)

      p1 = Payment.create!(order: order, provider: "stripe", status: "paid")
      p2 = Payment.create!(order: order, provider: "paypal", status: "paid")

      expect(order.payments).to contain_exactly(p1, p2)
    end

    context "when destroying an order" do
      it "destroys associated payments" do
        customer = Customer.create!(name: Faker::Name.name)
        order = described_class.create!(customer: customer)
        payment = Payment.create!(order: order, provider: "stripe", status: "paid")

        expect { order.destroy }.to change { Payment.count }.by(-1)
        expect { payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "does not destroy the associated customer" do
        customer = Customer.create!(name: Faker::Name.name)
        order = described_class.create!(customer: customer)

        expect { order.destroy }.not_to change { Customer.count }
        expect(customer.reload).to be_present
      end
    end
  end
end
