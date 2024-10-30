require 'rails_helper'

RSpec.describe "Items API", type: :request do 
  before(:each) do
    @item1 = Item.create(
      name: "Catnip Toy",
      description: "A soft toy filled with catnip.",
      unit_price: 12.99,
      merchant_id: @merchant.id
    )

    @item2 = Item.create(
      name: "Laser Pointer",
      description: "A laser pointer to keep your cat active.",
      unit_price: 9.99,
      merchant_id: @merchant.id
    )

    @item3 = Item.create(
      name: "Feather Wand",
      description: "A wand with feathers to entice your kitty.",
      unit_price: 15.50,
      merchant_id: @merchant.id
    )
  end

  describe 'GET /api/v1/items' do
    it 'can fetch all items' do
      get '/api/v1/items'
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      items = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(items).to be_an(Array)

      item = items[0]
      expect(item[:id]).to be_an(Integer)
      expect(item[:type]).to eq('item')

      attrs = item[:attributes]
      expect(attrs[:name]).to be_an(String)
      expect(attrs[:description]).to be_an(String)
      expect(attrs[:unit_price]).to be_a(Float)
      expect(attrs[:merchant_id]).to be_an(Integer)
    end    
  end

  describe 'GET /api/v1/items/:id' do
    it 'can fetch an individual item' do
      get "/api/v1/items/#{@item1.id}"
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      
      item = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(item[:id]).to eq(@item1.id)
      expect(item[:type]).to eq('item')

      attrs = item[:attributes]
      
      expect(attrs[:name]).to eq(@item1.name)
      expect(attrs[:description]).to eq(@item1.description)
      expect(attrs[:unit_price]).to eq(@item1.unit_price)
      expect(attrs[:merchant_id]).to eq(@item1.merchant_id)
    end
  end
end