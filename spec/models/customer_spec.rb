require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "associations" do
    it "has many orders", :stage_1 do
      customer = described_class.create!(name: Faker::Name.name)
      order1 = Order.create!(customer: customer)
      order2 = Order.create!(customer: customer)

      expect(customer.orders).to contain_exactly(order1, order2)
    end

    it "has many payments through orders", :stage_1 do
      customer = described_class.create!(name: Faker::Name.name)
      order1 = Order.create!(customer: customer)
      order2 = Order.create!(customer: customer)

      p1 = Payment.create!(order: order1, provider: "stripe", status: "paid")
      p2 = Payment.create!(order: order2, provider: "stripe", status: "paid")

      expect(customer.payments).to contain_exactly(p1, p2)
    end

    it "has one latest payment", :stage_2 do
      customer = described_class.create!(name: Faker::Name.name)
      order1 = Order.create!(customer: customer)
      order2 = Order.create!(customer: customer)

      Payment.create!(order: order1, provider: "stripe", status: "paid")
      latest = Payment.create!(order: order2, provider: "paypal", status: "paid")

      expect(customer.latest_payment).to eq(latest)
    end

    context "when destroying a customer", :stage_1 do
      let(:customer) { described_class.create!(name: Faker::Name.name) }

      let!(:order1) { Order.create!(customer: customer) }
      let!(:order2) { Order.create!(customer: customer) }

      let!(:payment1) { Payment.create!(order: order1, provider: "stripe", status: "paid") }
      let!(:payment2) { Payment.create!(order: order2, provider: "stripe", status: "paid") }

      it "destroys all its associated orders and payments" do
        expect { customer.destroy }.to change { Order.count }.by(-2)
                                                             .and change { Payment.count }.by(-2)

        expect { customer.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { order1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { payment1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
