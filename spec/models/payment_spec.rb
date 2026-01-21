require "rails_helper"

RSpec.describe Payment, :stage_1 do
  describe "associations" do
    it "belongs to an order" do
      customer = Customer.create!(name: Faker::Name.name)
      order = Order.create!(customer: customer)
      payment = described_class.new(order: order, provider: "stripe", status: "paid")

      expect(payment.order).to eq(order)
    end

    context "when destroying a payment" do
      it "does not destroy the associated order" do
        customer = Customer.create!(name: Faker::Name.name)
        order = Order.create!(customer: customer)
        payment = described_class.create!(order: order, provider: "stripe", status: "paid")

        expect { payment.destroy }.not_to change { Order.count }
        expect { payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(order.reload).to be_present
      end

      it "does not destroy the associated customer" do
        customer = Customer.create!(name: Faker::Name.name)
        order = Order.create!(customer: customer)
        payment = described_class.create!(order: order, provider: "stripe", status: "paid")

        expect { payment.destroy }.not_to change { Customer.count }
        expect(customer.reload).to be_present
      end
    end
  end

  describe "validations" do
    it "validates presence of provider" do
      customer = Customer.create!(name: Faker::Name.name)
      order = Order.create!(customer: customer)

      payment = described_class.new(order: order, status: "paid")
      expect(payment).not_to be_valid
      expect(payment.errors[:provider]).to contain_exactly("can't be blank")
    end

    it "validates presence of status" do
      customer = Customer.create!(name: Faker::Name.name)
      order = Order.create!(customer: customer)

      payment = described_class.new(order: order, provider: "stripe")
      expect(payment).not_to be_valid
      expect(payment.errors[:status]).to contain_exactly("can't be blank")
    end
  end
end
