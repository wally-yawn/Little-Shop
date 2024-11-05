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
      get "/api/v1/merchants/999/invoices"

        expect(response).to have_http_status(:not_found)
      error_response = JSON.parse(response.body, symbolize_names: true)
        expect(error_response).to have_key(:error)
        expect(error_response[:error]).to eq("Merchant not found")
    end


  describe 'POST /api/v1/merchants/:merchant_id/invoices' do
    it 'creates a new invoice' do
      invoice_params = { invoice: { customer_id: @customer.id, status: "pending" } }

      expect {
      post "/api/v1/merchants/#{@merchant.id}/invoices", params: invoice_params
      }.to change(Invoice, :count).by(1)   
      expect(response).to be_successful   
      new_invoice = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(new_invoice).to have_key(:id)
      expect(new_invoice[:attributes]).to have_key(:status)
      expect(new_invoice[:attributes][:status]).to eq("pending")
      expect(new_invoice[:attributes]).to have_key(:customer_id)
      expect(new_invoice[:attributes][:customer_id]).to eq(@customer.id)
    end

    it 'returns a 422 error if invoice parameters are missing' do
      post "/api/v1/merchants/#{@merchant.id}/invoices", params: { invoice: { status: "pending" } }
    
      expect(response).to have_http_status(:unprocessable_entity)
      error_response = JSON.parse(response.body, symbolize_names: true)
      expect(error_response).to have_key(:errors)
      expect(error_response[:errors]).to include("Customer must exist")
    end

    it 'returns a 404 error if the merchant does not exist when creating an invoice' do
      post "/api/v1/merchants/999/invoices", params: { invoice: { customer_id: @customer.id, status: "pending" } }

      expect(response).to have_http_status(:not_found)
      error_response = JSON.parse(response.body, symbolize_names: true)
      expect(error_response).to have_key(:error)
      expect(error_response[:error]).to eq("Merchant not found")
    end
  end
end
