require "rails_helper"

RSpec.describe "Merchants API" do
  describe "fetches merchants" do
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
    end

    it "can fetch a single merchant" do
      # binding.pry
      get "/api/v1/merchants"
      expect(response).to be_successful
    end
  end
end