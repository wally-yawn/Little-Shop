require 'rails_helper'

RSpec.describe "merchants update action" do
  describe "happy path test" do  
    it "can update a merchant" do
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')

      current_name = @merchant4.name
      updated_name = { name: 'Sweep the leg, Johnny' }

      patch "/api/v1/merchants/#{@merchant4.id}", params: updated_name
      expect(response).to be_successful

      merchant_response = JSON.parse(response.body)

      expect(merchant_response).to have_key("data")
      expect(merchant_response["data"]["id"]).to eq(@merchant4.id.to_s)
      expect(merchant_response["data"]["type"]).to eq("merchant")
      expect(merchant_response["data"]["attributes"]["name"]).to eq('Sweep the leg, Johnny')
    
      updated_merchant = Merchant.find(@merchant4.id)
      expect(updated_merchant.name).to_not eq('Jonathan')
      expect(updated_merchant.name).to eq('Sweep the leg, Johnny')
    end
  end
end