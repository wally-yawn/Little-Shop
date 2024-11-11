require 'rails_helper'

RSpec.describe "Coupons API", type: :request do 
  before(:each) do
    @merchant1 = Merchant.create!(name: 'Wally Wallace')
    @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant1.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
    @customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
    @coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "inactive", code: "COUP2", off: 5, percent_or_dollar: "percent")
  end

  describe 'show' do
    it 'can fetch an individual coupon' do
      get "/api/v1/coupons/#{@coupon1.id}"
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon[:id]).to eq(@coupon1.id.to_s)
      expect(coupon[:type]).to eq('coupon')

      attrs = coupon[:attributes]

      expect(attrs[:name]).to eq(@coupon1.name)
      expect(attrs[:status]).to eq(@coupon1.status)
      expect(attrs[:code]).to eq(@coupon1.code)
      expect(attrs[:off]).to eq(@coupon1.off)
      expect(attrs[:percent_or_dollar]).to eq(@coupon1.percent_or_dollar)
      expect(attrs[:merchant_id]).to eq(@coupon1.merchant_id)
      expect(attrs[:count_invoices]).to eq(0)
    end

    it 'returns the count of times used' do
      @customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
      @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: @coupon1)
      get "/api/v1/coupons/#{@coupon1.id}"
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon[:id]).to eq(@coupon1.id.to_s)
      expect(coupon[:attributes][:count_invoices]).to eq(1)
    end

    it 'returns an error if coupon is not found' do
      missing_id = @coupon1.id
      @coupon1.destroy

      get "/api/v1/coupons/#{missing_id}"
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("your request could not be completed") 
      expect(data[:errors]).to be_a(Array)
  
      error = data[:errors].first
      expect(error[:status]).to eq("404")
      expect(error[:title]).to eq("Couldn't find Coupon with 'id'=#{missing_id}") 
    end
  end

  describe 'create' do
    it 'can create a valid coupon' do
      coupon_params = { name: "Coupon2", merchant_id: @merchant1.id, status: "inactive", code: "CAPYBARA", off: 6.6, percent_or_dollar: "dollar"}
      post '/api/v1/coupons', params: {coupon: coupon_params}

      expect(response).to be_successful

      coupon_response = JSON.parse(response.body)

      expect(coupon_response).to have_key("data")
      expect(coupon_response["data"]["id"]).to be_present
      expect(coupon_response["data"]["type"]).to eq("coupon")
      expect(coupon_response["data"]["attributes"]["name"]).to eq("Coupon2")
      expect(coupon_response["data"]["attributes"]["status"]).to eq("inactive")
      expect(coupon_response["data"]["attributes"]["code"]).to eq("CAPYBARA")
      expect(coupon_response["data"]["attributes"]["off"]).to eq(6.6)
      expect(coupon_response["data"]["attributes"]["percent_or_dollar"]).to eq("dollar")
      expect(coupon_response["data"]["attributes"]["merchant_id"]).to eq(@merchant1.id)
      expect(coupon_response["data"]["attributes"]["count_invoices"]).to eq(0)
    end

    it 'returns an error when the merchant does not exist' do
      missing_merchant = @merchant1.id
      @merchant1.destroy

      coupon_params = { name: "Coupon2", merchant_id: @merchant1.id, status: "inactive", code: "CAPYBARA", off: 6.6, percent_or_dollar: "dollar"}
      
      post '/api/v1/coupons', params: {coupon: coupon_params}
      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"].first["title"]).to eq("Couldn't find Merchant with 'id'=#{missing_merchant}")
    end

    it 'returns an error when the required parameters are not supplied' do
      coupon_params = { name: "Coupon2", status: "inactive", code: "CAPYBARA", off: 6.6, percent_or_dollar: "dollar"}
      
      post '/api/v1/coupons', params: {coupon: coupon_params}
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"].first["title"]).to eq("Couldn't find Merchant without an ID")
    end

    it 'returns an error if there are already 5 active coupons' do
      coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant1.id, status: "active", code: "COUP3", off: 5, percent_or_dollar: "percent")
      coupon4 = Coupon.create!(name: "Coupon 4", merchant_id: @merchant1.id, status: "active", code: "COUP4", off: 5, percent_or_dollar: "percent")
      coupon5 = Coupon.create!(name: "Coupon 5", merchant_id: @merchant1.id, status: "active", code: "COUP5", off: 5, percent_or_dollar: "percent")
      coupon6 = Coupon.create!(name: "Coupon 6", merchant_id: @merchant1.id, status: "active", code: "COUP6", off: 5, percent_or_dollar: "percent")
      
      coupon_params = { name: "Coupon6", merchant_id: @merchant1.id, status: "active", code: "COUP6", off: 6.6, percent_or_dollar: "dollar"}
      
      post '/api/v1/coupons', params: {coupon: coupon_params}

      expect(response).to_not be_successful
      expect(response.status).to eq(422)
      
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("your request could not be completed") 
      expect(data[:errors]).to be_a(Array)
  
      error = data[:errors].first
      expect(error[:status]).to eq("422")
      expect(error[:title]).to eq("Merchant #{@merchant1.id} already has 5 active coupons") 
    end
  end

  describe 'deactivate' do
    it 'can deactivate an active coupon' do
      patch "/api/v1/coupons/#{@coupon1.id}/deactivate"

      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon[:id]).to eq(@coupon1.id.to_s)
      expect(coupon[:attributes][:status]).to eq("inactive")
      @coupon1.reload
      expect(@coupon1.status).to eq("inactive")
    end

    it 'cannot deactivate an active coupon with pending invoices' do
      @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged", coupon: @coupon1)
      patch "/api/v1/coupons/#{@coupon1.id}/deactivate"

      expect(response).to_not be_successful
      expect(response.status).to eq(422)
      

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("your request could not be completed") 
      expect(data[:errors]).to be_a(Array)
  
      error = data[:errors].first
      expect(error[:status]).to eq("422")
      expect(error[:title]).to eq("This coupon applies to pending invoices") 

    end

    it 'can deactivate an active coupon with shipped invoices' do
      @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: @coupon1)
      patch "/api/v1/coupons/#{@coupon1.id}/deactivate"

      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon[:id]).to eq(@coupon1.id.to_s)
      expect(coupon[:attributes][:status]).to eq("inactive")
      @coupon1.reload
      expect(@coupon1.status).to eq("inactive")
    end

    it 'returns an error if the coupon does not exist' do
      missing_id = @coupon1.id
      @coupon1.destroy

      patch "/api/v1/coupons/#{@coupon1.id}/deactivate"
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("your request could not be completed") 
      expect(data[:errors]).to be_a(Array)
  
      error = data[:errors].first
      expect(error[:status]).to eq("404")
      expect(error[:title]).to eq("Couldn't find Coupon with 'id'=#{missing_id}") 
    end
  end

  describe 'activate' do
    it 'can activate an inactive coupon' do
      patch "/api/v1/coupons/#{@coupon2.id}/activate"

      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon[:id]).to eq(@coupon2.id.to_s)
      expect(coupon[:attributes][:status]).to eq("active")
      @coupon2.reload
      expect(@coupon2.status).to eq("active")

    end

    it 'cannot activate an inactive coupon if there are already 5 active coupons' do
      coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant1.id, status: "active", code: "COUP3", off: 5, percent_or_dollar: "percent")
      coupon4 = Coupon.create!(name: "Coupon 4", merchant_id: @merchant1.id, status: "active", code: "COUP4", off: 5, percent_or_dollar: "percent")
      coupon5 = Coupon.create!(name: "Coupon 5", merchant_id: @merchant1.id, status: "active", code: "COUP5", off: 5, percent_or_dollar: "percent")
      coupon6 = Coupon.create!(name: "Coupon 6", merchant_id: @merchant1.id, status: "active", code: "COUP6", off: 5, percent_or_dollar: "percent")
      
      patch "/api/v1/coupons/#{@coupon2.id}/activate"

      expect(response).to_not be_successful
      expect(response.status).to eq(422)
      

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("your request could not be completed") 
      expect(data[:errors]).to be_a(Array)
  
      error = data[:errors].first
      expect(error[:status]).to eq("422")
      expect(error[:title]).to eq("Merchant #{@merchant1.id} already has 5 active coupons") 
    end

    it 'returns an error if the coupon does not exist' do
      missing_id = @coupon2.id
      @coupon2.destroy

      patch "/api/v1/coupons/#{@coupon2.id}/deactivate"
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("your request could not be completed") 
      expect(data[:errors]).to be_a(Array)
  
      error = data[:errors].first
      expect(error[:status]).to eq("404")
      expect(error[:title]).to eq("Couldn't find Coupon with 'id'=#{missing_id}") 
    end
  end
end



