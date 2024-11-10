require "rails_helper"

RSpec.describe "Merchants Coupon API" do
  before :each do
    @merchant1 = Merchant.create(name: 'Wally')
    @merchant2 = Merchant.create(name: 'Dahlia')
    @merchant2 = Merchant.create(name: 'Brinklee')
    @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant1.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
    @coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "inactive", code: "COUP2", off: 10, percent_or_dollar: "dollar")
    @coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant2.id, status: "inactive", code: "COUP3", off: 1, percent_or_dollar: "dollar")
    @customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: @coupon1)
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice3 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: @coupon2)
  end
  
  describe "fetches merchant coupons" do
    it 'fetches all coupons for the merchant' do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"
      expect(response).to be_successful
      merchant_coupons = JSON.parse(response.body)

      expect(merchant_coupons["data"][0]["id"]).to eq(@coupon1.id.to_s)
      expect(merchant_coupons["data"][1]["id"]).to eq(@coupon2.id.to_s)
      
      merchant_coupons["data"].each do |coupon|
        expect(coupon).to have_key("id")
        expect(coupon["id"]).to be_a(String)
        expect(coupon).to have_key("type")
        expect(coupon["type"]).to eq("coupon")
        expect(coupon["attributes"]).to have_key("name")
        expect(coupon["attributes"]["name"]).to be_a(String)
        expect(coupon["attributes"]).to have_key("merchant_id")
        expect(coupon["attributes"]["merchant_id"]).to be_a(Integer)
        expect(coupon["attributes"]).to have_key("status")
        expect(coupon["attributes"]["status"]).to be_a(String)
        expect(coupon["attributes"]).to have_key("code")
        expect(coupon["attributes"]["code"]).to be_a(String)
        expect(coupon["attributes"]).to have_key("off")
        expect(coupon["attributes"]["off"]).to be_a(Float)
        expect(coupon["attributes"]).to have_key("percent_or_dollar")
        expect(coupon["attributes"]["percent_or_dollar"]).to be_a(String)
        expect(coupon["attributes"]).to have_key("count_invoices")
        expect(coupon["attributes"]["count_invoices"]).to be_a(Integer)
      end

    end

    it 'does not error when the merchant exists but no coupons exist' do

    end

    it 'returns an error when the merchant does not exist' do

    end
  end
end