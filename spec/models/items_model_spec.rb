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
      result = Item.sort_by_price
      expect(result).to match_array([@item1, @item2, @item3])
    end

    it 'returns items sorted by unit_price when sort_order is "price"' do
      result = Item.sort_by_price('price')
      expect(result).to eq([@item2, @item1, @item3]) 
    end
end 