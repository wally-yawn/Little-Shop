require "rails_helper"

RSpec.describe "Merchants API" do
  describe "fetches merchants" do
    before :each do
      Merchant.destroy_all
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')
    end

    describe 'fetch multiple merchants' do
      it "can fetch multiple merchants when no coupons or invoice coupons exist" do
        get "/api/v1/merchants"
        expect(response).to be_successful
        merchants = JSON.parse(response.body)
        expect(merchants["data"].count).to eq(4)

        merchants["data"].each do |merchant|
          expect(merchant).to have_key("id")
          expect(merchant["id"]).to be_a(String)
          expect(merchant).to have_key("type")
          expect(merchant["type"]).to eq("merchant")
          expect(merchant["attributes"]).to have_key("name")
          expect(merchant["attributes"]["name"]).to be_a(String)
          expect(merchant["attributes"]["coupons_count"]).to eq(0)
          expect(merchant["attributes"]["invoice_coupon_count"]).to eq(0)
        end
      end

      xit 'returns coupons and invoice coupon counts when coupons and invoice coupons exist' do

      end

      it "can fetch all merchants when there are no merchants" do
        Merchant.destroy_all
        
        get "/api/v1/merchants"
        expect(response).to be_successful
        merchants = JSON.parse(response.body)
        expect(merchants["data"].count).to eq(0)
      end
    end

      describe 'it can sort merchants' do
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
    end

    describe 'returns merchants with returns' do
      it "can returns only merchants with returns" do
        customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
        invoice1 = Invoice.create!(customer_id: "#{customer1.id}", merchant_id: "#{@merchant1.id}", status: "returned")
        invoice2 = Invoice.create!(customer_id: "#{customer1.id}", merchant_id: "#{@merchant1.id}", status: "shipped")
        invoice3 = Invoice.create!(customer_id: "#{customer1.id}", merchant_id: "#{@merchant2.id}", status: "returned")
        invoice2 = Invoice.create!(customer_id: "#{customer1.id}", merchant_id: "#{@merchant3.id}", status: "shipped")

        get "/api/v1/merchants?status=returned"
        expect(response).to be_successful
        merchants = JSON.parse(response.body)
        expect(merchants["data"].count).to eq(2)
        expect(merchants["data"][0]["id"]).to eq("#{@merchant1.id}")
        expect(merchants["data"][1]["id"]).to eq("#{@merchant2.id}")
      end

      it "can return merchants with returns when no merchants exist" do
        Merchant.destroy_all

        get "/api/v1/merchants?status=returned"
        expect(response).to be_successful
        merchants = JSON.parse(response.body)
        expect(merchants["data"].count).to eq(0)
      end

      it "can return merchants with returns when no merchants with returns exist" do
        get "/api/v1/merchants?status=returned"
        expect(response).to be_successful
        merchants = JSON.parse(response.body)
        expect(merchants["data"].count).to eq(0)
      end
    end

    describe 'fetch a single merchant' do
      xit 'can fetch a single merchant by id' do
        get "/api/v1/merchants/#{@merchant1.id}"
        expect(response).to be_successful
        merchant = JSON.parse(response.body)

        expect(merchant["data"]).to have_key("id")
        expect(merchant["data"]["id"]).to be_a(String)
        expect(merchant["data"]).to have_key("type")
        expect(merchant["data"]["type"]).to eq("merchant")
        expect(merchant["data"]["attributes"]).to have_key("name")
        expect(merchant["data"]["attributes"]["name"]).to eq("Wally")
      end

      it "returns an error when the merchant_id does not exist" do
        missing_id = @merchant2.id
        @merchant2.destroy

        get "/api/v1/merchants/#{missing_id}"
        expect(response).to_not be_successful
        expect(response.status).to eq(404)
    
        data = JSON.parse(response.body, symbolize_names: true)
    
        expect(data[:errors]).to be_a(Array)
    
        expect(data[:message]).to eq("your query could not be completed") 
        expect(data[:errors].first).to eq("Couldn't find Merchant with 'id'=#{missing_id}") 
      end
    end
    
    describe 'include item count' do 
      xit "includes an item count when asked" do
        @item1 = Item.create(
        name: "Catnip Toy",
        description: "A soft toy filled with catnip.",
        unit_price: 12.99,
        merchant_id: @merchant1.id
        )
        @item2 = Item.create(
        name: "Laser Pointer",
        description: "A laser pointer to keep your cat active.",
        unit_price: 9.99,
        merchant_id: @merchant1.id
        )

        get "/api/v1/merchants?count=true"
        expect(response).to be_successful
        # binding.pry
        merchants = JSON.parse(response.body)

        expect(merchants["data"].count).to eq(4)
        merchants["data"].each do |merchant|
          expect(merchant).to have_key("id")
          expect(merchant["attributes"]).to have_key("name")
          expect(merchant["attributes"]).to have_key("item_count")

          individual_merchant = Merchant.find(merchant["id"].to_i)
          expect(merchant["attributes"]["item_count"]).to eq(individual_merchant.items.count)
        end
      end

      it "does not include item count when not asked for" do
        get "/api/v1/merchants"
        expect(response).to be_successful
      
        merchants = JSON.parse(response.body)
      
        expect(merchants["data"].count).to eq(4)
        merchants["data"].each do |merchant|
          expect(merchant["attributes"]).to have_key("name")
          expect(merchant["attributes"]).to_not have_key("item_count")
        end
      end
    end

    describe 'fetch all items for a given merchant' do
      it "can fetch all items for a given merchant" do
        @item1 = Item.create(
          name: "Catnip Toy",
          description: "A soft toy filled with catnip.",
          unit_price: 12.99,
          merchant_id: @merchant1.id
        )

        @item2 = Item.create(
          name: "Laser Pointer",
          description: "A laser pointer to keep your cat active.",
          unit_price: 9.99,
          merchant_id: @merchant1.id
        )

        get "/api/v1/merchants/#{@merchant1.id}/items"

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)[:data]
        expect(items).to be_an(Array)

        item1 = items[0]
        expect(item1[:id].to_i).to be_an(Integer)
        expect(item1[:type]).to eq('item')

        attrs1 = item1[:attributes]

        expect(attrs1[:name]).to eq("Catnip Toy")
        expect(attrs1[:description]).to eq("A soft toy filled with catnip.")
        expect(attrs1[:unit_price]).to eq(12.99)
        expect(attrs1[:merchant_id]).to eq(@merchant1.id)

        item2 = items[1]
        expect(item2[:id].to_i).to be_an(Integer)
        expect(item2[:type]).to eq('item')

        attrs2 = item2[:attributes]

        expect(attrs2[:name]).to eq("Laser Pointer")
        expect(attrs2[:description]).to eq("A laser pointer to keep your cat active.")
        expect(attrs2[:unit_price]).to eq(9.99)
        expect(attrs2[:merchant_id]).to eq(@merchant1.id)
      end

      it "can fetch all items for a given merchant when none exist" do
        Item.destroy_all
        
        get "/api/v1/merchants/#{@merchant1.id}/items"
        expect(response).to be_successful
        items = JSON.parse(response.body)
        expect(items["data"].count).to eq(0)
      end

      it "returns an error when attempting to fetch all items for a given merchant that does not exist" do
        missingMerchant = @merchant1.id
        @merchant1.destroy
  
        get "/api/v1/merchants/#{missingMerchant}/items"

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        error_response = JSON.parse(response.body)
        expect(error_response["message"]).to eq("your query could not be completed")
        expect(error_response["errors"]).to include("Couldn't find Merchant with 'id'=#{missingMerchant}")
      end
    end

    describe 'includes invoices' do
      it "includes invoices based on status when requested" do
        Invoice.destroy_all
        customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
        invoice1 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "shipped")
        invoice2 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "returned")
        invoice3 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "packaged")
        invoice4 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "returned")

        status = "returned"
        get "/api/v1/merchants/#{@merchant1.id}/invoices?status=#{status}"
        
        expect(response).to be_successful
        invoices = JSON.parse(response.body)
        expect(invoices["data"].count).to eq(2)
        expect(invoices["data"][0]["id"]).to eq(invoice2.id.to_s)
        expect(invoices["data"][1]["id"]).to eq(invoice4.id.to_s)
      end

      it "includes invoices based on status when requested when there are none" do
        Invoice.destroy_all
        customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
        invoice1 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "shipped")
        invoice2 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "returned")
        invoice3 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "shipped")
        invoice4 = Invoice.create!(customer_id: customer1.id, merchant_id: @merchant1.id, status: "returned")

        status = "packaged"
        get "/api/v1/merchants/#{@merchant1.id}/invoices?status=#{status}"
        
        expect(response).to be_successful
        invoices = JSON.parse(response.body)
        expect(invoices["data"].count).to eq(0)
      end
    end

    describe 'find' do
      it 'finds the first matching merchant by name (case insensitive)' do
        get '/api/v1/merchants/find?name=na'

        expect(response).to be_successful

        merchant = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(merchant[:id]).to eq(@merchant3.id.to_s)
      end

      it 'does not error when there are no matching merchants' do
        get '/api/v1/merchants/find?name=abdul'
        expect(response).to be_successful
      end
    end
  end
end