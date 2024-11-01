require 'rails_helper'

RSpec.describe "Items API", type: :model do 
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
      @merchant2.destroy
      response = Item.getItems({ id: @merchant2.id })
      expect(true).to eq(false)
    end
end 