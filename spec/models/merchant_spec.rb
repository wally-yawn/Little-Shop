require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items)}
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  before :each do
    @merchant1 = Merchant.create(name: 'Wally')
    @merchant2 = Merchant.create(name: 'James')
    @merchant3 = Merchant.create(name: 'Natasha')
    @merchant4 = Merchant.create(name: 'Jonathan')

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
  end
  describe "sort" do
    it "can sort merchants based on age" do
      merchants = Merchant.sort({sorted: "age"})

      expect(merchants[0].created_at).to be > (merchants[1].created_at)
      expect(merchants[1].created_at).to be > (merchants[2].created_at)
      expect(merchants[2].created_at).to be > (merchants[3].created_at)
    end

    it "ignores sort if not passed as a parameter" do
      merchants = Merchant.sort({nonsense: "Fun nonsense"})
      expect(merchants[0].created_at).to be < (merchants[1].created_at)
      expect(merchants[1].created_at).to be < (merchants[2].created_at)
      expect(merchants[2].created_at).to be < (merchants[3].created_at)
    end
  end

  describe "dependent destroy" do
    before :each do
      Item.destroy_all
    end
    it "destroys associated items when the merchant is deleted" do
      merchant = Merchant.create!(name: 'Frankenstein')
      item1 = merchant.items.create!(name: 'Head bolts', description: 'used as ears and to hold head on', unit_price: 10.99)
      item2 = merchant.items.create!(name: 'Thread', description: 'Used to sew limbs to body', unit_price: 20.99)
      expect(Item.count).to eq(2)
      
      merchant.destroy
      expect(Item.count).to eq(0)
    end
  end

  describe "queried" do
    it "returns merchants with item count when count param is 'true'" do
      merchants = Merchant.queried({ count: 'true' })
      merchant_with_items = merchants.find_by(id: @merchant1.id)
      
      expect(merchant_with_items.item_count).to eq(2)
    end

    it "does not include item count when count param is not present" do
      merchants = Merchant.queried({})
      expect(merchants.first).to_not respond_to(:item_count)
    end
  end
end