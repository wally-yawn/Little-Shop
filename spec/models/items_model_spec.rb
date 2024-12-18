require 'rails_helper'

RSpec.describe Item, type: :model do 
  describe "relationships" do
    it { should have_many(:invoice_items) }
    it { should belong_to(:merchant) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:merchant_id) }
  end

  before(:each) do
    @merchant = Merchant.create(name: "Awesome Merchant") 
    Item.destroy_all
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

  it 'returns all items when sort_order is not "price"' do
    result = Item.getItems
    expect(result).to match_array([@item1, @item2, @item3])
  end

  it 'returns items sorted by unit_price when sort_order is "price"' do
    result = Item.getItems({ sorted: 'price' })
    expect(result).to eq([@item2, @item1, @item3]) 
  end

  it 'returns all items for a given merchant' do
    @merchant2 = Merchant.create(name: "Awesome Merchant 2") 
    @item4 = Item.create(
      name: "Stuffed Bee",
      description: "A bee to entertain.",
      unit_price: 18.50,
      merchant_id: @merchant2.id
    )
    merchant1Items = Item.getItems({ id: @merchant.id })
    merchant2Items = Item.getItems({ id: @merchant2.id })
    expect(merchant1Items.length).to eq(3)
    expect(merchant2Items.length).to eq(1)
    expect(merchant1Items[0]).to eq(@item1)
  end

  it 'returns all items for a given merchant when there are none' do
    Item.destroy_all
    merchant1Items = Item.getItems({ id: @merchant.id })
    expect(merchant1Items).to eq([])
  end

  it 'errors when the given merchant does not exist' do
    @merchant2 = Merchant.create(name: "Awesome Merchant 2")
    missingMerchant = @merchant2.id
    @merchant2.destroy
    response = Item.getItems({ id: missingMerchant })
    expect(response).to eq("Couldn't find Merchant with 'id'=#{missingMerchant}")
  end

  it "destroys associated invoice_items when the item is deleted" do
    customer = Customer.create!(first_name: "Wally", last_name: "Wallace")
    invoice = Invoice.create!(customer_id: customer.id, merchant_id: @merchant.id, status: "shipped")
    invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: @merchant.id, status: "returned")
    invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: invoice.id, quantity: 3, unit_price: 9.99)
    invoice_item2 = InvoiceItem.create!(item_id: @item1.id, invoice_id: invoice2.id, quantity: 2, unit_price: 10.99)
    @item1.destroy
    expect(InvoiceItem.count).to eq(0)
  end

  describe 'find_all' do
    it 'can find all items that match a name search query' do
      items = Item.find_all({ name: 'cat' })

      expect(items.size).to eq(1)
      expect(items[0].name.downcase).to include("cat")
    end

    it 'returns an empty array when no items match the search query' do
      items = Item.find_all({ name: 'nonexistent' })
      expect(items).to eq([])
    end

    it 'can fetch all items that match a min price search query' do
      items = Item.find_all({ min_price: 10 })

      expect(items[0][:id]).to eq(@item1.id)
      expect(items[1][:id]).to eq(@item3.id)
    end

    it 'can fetch all items that match a max price search query' do
      items = Item.find_all({ max_price: 13 })

      expect(items[0][:id]).to eq(@item1.id)
      expect(items[1][:id]).to eq(@item2.id)
    end

    it 'can fetch all items that match a min and max price search query' do
      items = Item.find_all({ min_price: 10, max_price: 13 })
      expect(items[0][:id]).to eq(@item1.id)
    end

    it 'returns an error if both price and name are passed in' do
      items = Item.find_all({ min_price: 10, max_price: 13, name: "hello"})
      expect(items).to be_a(Hash)
      items = Item.find_all({ max_price: 13, name: "hello"})
      expect(items).to be_a(Hash)
      items = Item.find_all({ min_price: 10, name: "hello"})
      expect(items).to be_a(Hash)
    end
  end
end