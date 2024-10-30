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
  end
end