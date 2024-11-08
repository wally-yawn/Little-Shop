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
      expect(invoice[:attributes]).to have_key(:status)
      expect(invoice[:attributes][:status]).to be_a(String)
    end
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