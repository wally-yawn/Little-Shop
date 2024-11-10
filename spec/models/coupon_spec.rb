require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe "relationships" do
    it { should have_many(:invoices)}
    it { should belong_to(:merchant)}
  end

  before :each do
    @merchant1 = Merchant.create!(name: 'Wally Wallace')
    @merchant2 = Merchant.create!(name: 'Dahlia Wallace')
    @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant1.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
    @customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "returned", coupon: @coupon1)
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    end

  describe 'count_invoices' do
    it 'returns the count of invoices with this coupon' do
      expect(@coupon1.count_invoices).to eq(1)
    end
  end
end