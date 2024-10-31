require "rails_helper"

RSpec.describe "Merchants API" do
  describe "fetches merchants" do
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')
    end

    it "can fetch multiple merchants" do
      get "/api/v1/merchants"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      expect(merchants["data"].count).to eq(4)

      merchants["data"].each do |merchant|
        expect(merchant).to have_key("id")
        expect(merchant["id"]).to be_a(Integer)
        expect(merchant).to have_key("type")
        expect(merchant["type"]).to eq("merchant")
        expect(merchant["attributes"]).to have_key("name")
        expect(merchant["attributes"]["name"]).to be_a(String)
      end
    end

    it "can fetch all merchants when there are no merchants" do
      Merchant.destroy_all
      
      get "/api/v1/merchants"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      expect(merchants["data"].count).to eq(0)
    end

    it "can sort merchants based on age" do
      get "/api/v1/merchants?sorted=age"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      
      expect(merchants["data"].count).to eq(4)
      expect(merchants["data"][0]["id"]).to be > (merchants["data"][1]["id"])
      expect(merchants["data"][1]["id"]).to be > (merchants["data"][2]["id"])
      expect(merchants["data"][2]["id"]).to be > (merchants["data"][3]["id"])
    end

    it "can sort merchants based on age when there is a gap in ids" do
      @merchant3.destroy
      get "/api/v1/merchants?sorted=age"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      
      expect(merchants["data"].count).to eq(3)
      expect(merchants["data"][0]["id"]).to be > (merchants["data"][1]["id"])
      expect(merchants["data"][1]["id"]).to be > (merchants["data"][2]["id"])
    end

    it "can sort merchants based on age when no merchants exist" do
      Merchant.destroy_all

      get "/api/v1/merchants?sorted=age"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      expect(merchants["data"].count).to eq(0)
    end


    it 'can fetch a single merchant by id' do
      get "/api/v1/merchants/#{@merchant1.id}"
      expect(response).to be_successful
      merchant = JSON.parse(response.body)

      expect(merchant["data"]).to have_key("id")
      expect(merchant["data"]["id"]).to be_a(Integer)
      expect(merchant["data"]).to have_key("type")
      expect(merchant["data"]["type"]).to eq("merchant")
      expect(merchant["data"]["attributes"]).to have_key("name")
      expect(merchant["data"]["attributes"]["name"]).to eq("Wally")
    end

    it "returns an error when the merchant_id does not exist" do
      expect(true).to eq(false)
    end
  end
end