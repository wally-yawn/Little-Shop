require 'rails_helper'

RSpec.describe "Coupons API", type: :request do 
  before(:each) do
    @merchant1 = Merchant.create!(name: 'Wally Wallace')
    @coupon1 = Coupon.create(name: "Coupon 1", merchant_id: @merchant1.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
  end

  describe 'index' do
    xit 'can fetch all coupons' do
      get '/api/v1/coupons'
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      coupons = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(coupons).to be_an(Array)

      coupon = coupons[0]
      expect(coupon[:id].to_i).to be_an(Integer)
      expect(coupon[:type]).to eq('coupon')

      attrs = coupon[:attributes]

      expect(attrs[:name]).to be_an(String)
      expect(attrs[:description]).to be_an(String)
      expect(attrs[:unit_price]).to be_a(Float)
      expect(attrs[:merchant_id]).to be_an(Integer)
    end  

    xit "can fetch all coupons when there are no coupons" do
      coupon.destroy_all
    
      get "/api/v1/coupons"
      expect(response).to be_successful
      coupons = JSON.parse(response.body)
      expect(coupons["data"].count).to eq(0)
    end
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
end



