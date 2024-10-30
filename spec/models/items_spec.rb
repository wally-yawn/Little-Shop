require 'rails_helper'

RSpec.describe "Items API", type: :request do
  describe "GET /api/v1/items" do
    before :each do
      create_list(:item, 3)
    end

    it "returns all items" do
      get '/api/v1/items'

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      # Parse JSON response
      items = JSON.parse(response.body)
      expect(items.count).to eq() # Assuming 3 items were created
    end
  end
end