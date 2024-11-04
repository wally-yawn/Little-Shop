require 'rails_helper'

RSpec.describe "Items API", type: :request do 
  before(:each) do
    @merchant = Merchant.create(name: "Awesome Merchant") 
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

  it 'can fetch all items' do
    get '/api/v1/items'
    
    expect(response).to be_successful
    expect(response.status).to eq(200)
    
    items = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(items).to be_an(Array)

    item = items[0]
    expect(item[:id].to_i).to be_an(Integer)
    expect(item[:type]).to eq('item')

    attrs = item[:attributes]

    expect(attrs[:name]).to be_an(String)
    expect(attrs[:description]).to be_an(String)
    expect(attrs[:unit_price]).to be_a(Float)
    expect(attrs[:merchant_id]).to be_an(Integer)
  end  

  it "can fetch all items when there are no items" do
    Item.destroy_all
  
    get "/api/v1/items"
    expect(response).to be_successful
    items = JSON.parse(response.body)
    expect(items["data"].count).to eq(0)
  end

  it 'can fetch an individual item' do
    get "/api/v1/items/#{@item1.id}"
    
    expect(response).to be_successful
    expect(response.status).to eq(200)
    
    item = JSON.parse(response.body, symbolize_names: true)[:data]
    
    expect(item[:id].to_i).to eq(@item1.id) # Convert `item[:id]` to integer
    expect(item[:type]).to eq('item')

    attrs = item[:attributes]
    
    expect(attrs[:name]).to eq(@item1.name)
    expect(attrs[:description]).to eq(@item1.description)
    expect(attrs[:unit_price]).to eq(@item1.unit_price)
    expect(attrs[:merchant_id]).to eq(@item1.merchant_id)
  end

  it 'returns a 404 when the item does not exist' do
    missing_id = @item1.id
    @item1.destroy

    get "/api/v1/items/#{@missing_id}"

    expect(response).to_not be_successful
    expect(response.status).to eq(404)

    data = JSON.parse(response.body, symbolize_names: true)

    expect(data[:errors]).to be_a(Array)
    expect(data[:errors].first[:status]).to eq("404")
    expect(data[:errors].first[:message]).to eq("Couldn't find Item with 'id'=#{missing_id}") 
  end

  it 'can sort items by price' do
    get '/api/v1/items', params: { sorted: 'price' }

    expect(response).to be_successful
    expect(response.status).to eq(200)
    
    items = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(items).to be_an(Array)
    
    expect(items[0][:id].to_i).to eq(@item2.id) 
    expect(items[1][:id].to_i).to eq(@item1.id) 
    expect(items[2][:id].to_i).to eq(@item3.id) 
  end

  it "can fetch multiple items" do
    get "/api/v1/items"
    expect(response).to be_successful
    items = JSON.parse(response.body)
    expect(items["data"].count).to eq(3)

    items["data"].each do |item|
      expect(item).to have_key("id")
      expect(item["id"]).to be_a(String)
      expect(item).to have_key("type")
      expect(item["type"]).to eq("item")
      expect(item["attributes"]).to have_key("name")
      expect(item["attributes"]["name"]).to be_a(String)
    end
  end

  it 'can return the merchant associated with an item' do
    get "/api/v1/items/#{@item1.id}/merchant"
    expect(response).to be_successful
    merchant = JSON.parse(response.body)

    expect(merchant["data"]).to have_key("id")
    expect(merchant["data"]["id"]).to be_a(String)
    expect(merchant["data"]).to have_key("type")
    expect(merchant["data"]["type"]).to eq("merchant")
    expect(merchant["data"]["attributes"]).to have_key("name")
    expect(merchant["data"]["attributes"]["name"]).to eq("Awesome Merchant")
  end

  it 'returns a 404 if an item id does not exist when requesting the merchant' do
    missing_id = @item1.id
    @item1.destroy

    get "/api/v1/items/#{@missing_id}/merchant"

    expect(response).to_not be_successful
    expect(response.status).to eq(404)

    data = JSON.parse(response.body, symbolize_names: true)

    expect(data[:errors]).to be_a(Array)
    expect(data[:errors].first[:status]).to eq("404")
    expect(data[:errors].first[:message]).to eq("Couldn't find Item with 'id'=#{missing_id}") 
  end
end