require "rails_helper"

RSpec.describe "Merchants Coupon API" do
  before :each do
    @merchant1 = Merchant.create(name: 'Wally')
    @merchant2 = Merchant.create(name: 'Dahlia')
    @merchant2 = Merchant.create(name: 'Brinklee')
    @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant1.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
    @coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "inactive", code: "COUP2", off: 10, percent_or_dollar: "dollar")
    @coupon2 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant2.id, status: "inactive", code: "COUP3", off: 1, percent_or_dollar: "dollar")
    @customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: @coupon1)
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice3 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: @coupon2)
  end
  
  describe "fetches merchant coupons" do
    it 'fetches all coupons for the merchant' do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)

    end

    it 'does not error when the merchant exists but not coupons exist' do

    end

    it 'returns an error when the merchant does not exist' do

    end
  end
end