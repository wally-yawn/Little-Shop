require 'rails_helper'

RSpec.describe 'Invoices API', type: :request do
  before(:each) do
    @merchant = Merchant.create!(name: "Merchant A")
    @customer = Customer.create!(first_name: "Lisa", last_name: "Reeve")
    @invoice1 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed")
    @invoice2 = Invoice.create!(customer: @customer, merchant: @merchant, status: "pending")
  end

  it 'returns all invoices associated with a merchant' do
    get "/api/v1/merchants/#{@merchant.id}/invoices"

    expect(response).to be_successful
    invoices = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(invoices.count).to eq(2)
    invoices.each do |invoice|
      expect(invoice).to have_key(:id)
      expect(invoice[:id]).to be_a(String)
      expect(invoice).to have_key(:type)
      expect(invoice[:type]).to eq("invoice")
      expect(invoice[:attributes]).to have_key(:customer_id)
      expect(invoice[:attributes][:customer_id]).to be_a(Integer)
      expect(invoice[:attributes]).to have_key(:merchant_id)
      expect(invoice[:attributes][:merchant_id]).to be_a(Integer)
      expect(invoice[:attributes]).to have_key(:coupon_id)
      expect(invoice[:attributes][:coupon_id]).to eq(nil)
      expect(invoice[:attributes]).to have_key(:status)
      expect(invoice[:attributes][:status]).to be_a(String)
    end
  end

  it 'returns the coupon_id if a coupon has been applied'do
    @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
    @coupon2 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant.id, status: "inactive", code: "COUP2", off: 6.6, percent_or_dollar: "dollar")
    @invoice1.coupon = @coupon1
    @invoice1.save
    @invoice2.coupon = @coupon2
    @invoice2.save

    get "/api/v1/merchants/#{@merchant.id}/invoices"

    expect(response).to be_successful
    invoices = JSON.parse(response.body, symbolize_names: true)[:data]
    
    expect(invoices[0][:attributes][:coupon_id]).to eq(@coupon1.id)
    expect(invoices[1][:attributes][:coupon_id]).to eq(@coupon2.id)
  end

  it 'returns an empty array if no invoices exist for a merchant' do
    new_merchant = Merchant.create!(name: "Merchant B")
    get "/api/v1/merchants/#{new_merchant.id}/invoices"

    expect(response).to be_successful
    invoices = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(invoices).to eq([]) 
  end

  it 'returns a 404 error if the merchant does not exist' do
    merchant_id = @merchant.id
    Merchant.destroy_all

    get "/api/v1/merchants/#{merchant_id}/invoices"

    expect(response).to have_http_status(404)
    error_response = JSON.parse(response.body, symbolize_names: true)
    expect(error_response).to have_key(:errors)
    expect(error_response[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=#{merchant_id}")
  end
end