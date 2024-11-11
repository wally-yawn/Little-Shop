require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe "relationships" do
    it { should have_many(:invoices)}
    it { should belong_to(:merchant)}
  end

  before :each do
    @merchant1 = Merchant.create!(name: 'Wally Wallace')
    @merchant2 = Merchant.create!(name: 'Dahlia Wallace')
    @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant1.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
    @customer1 = Customer.create!(first_name: "Wally", last_name: "Wallace")
    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "returned", coupon: @coupon1)
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    end

  describe 'count_invoices' do
    it 'returns the count of invoices with this coupon' do
      expect(@coupon1.count_invoices).to eq(1)
    end
  end

  describe 'deactivate' do
    it 'can deactivate a coupon' do
      @coupon1.deactivate
      expect(@coupon1.status).to eq("inactive")
    end

    it 'cannot deactivate a coupon that is on a pending invoice' do
      @invoice3 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged", coupon: @coupon1)
      expect{ @coupon1.deactivate }.to raise_error(CouponDeactivationError)
      expect(@coupon1.status).to eq("active")
    end
  end

  describe 'activate' do
    it 'can activate a coupon' do
      @coupon1.deactivate
      expect(@coupon1.status).to eq("inactive")
      @coupon1.activate
      expect(@coupon1.status).to eq("active")
    end

    it 'it cannot activate a coupon if the merchant already has 5 active coupons' do
      @coupon1.deactivate
      expect(@coupon1.status).to eq("inactive")

      coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "active", code: "COUP2", off: 5, percent_or_dollar: "percent")
      coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant1.id, status: "active", code: "COUP3", off: 5, percent_or_dollar: "percent")
      coupon4 = Coupon.create!(name: "Coupon 4", merchant_id: @merchant1.id, status: "active", code: "COUP4", off: 5, percent_or_dollar: "percent")
      coupon5 = Coupon.create!(name: "Coupon 5", merchant_id: @merchant1.id, status: "active", code: "COUP5", off: 5, percent_or_dollar: "percent")
      coupon6 = Coupon.create!(name: "Coupon 6", merchant_id: @merchant1.id, status: "active", code: "COUP6", off: 5, percent_or_dollar: "percent")
      expect{ @coupon1.activate }.to raise_error(FiveActiveCouponsError)
      expect(@coupon1.status).to eq("inactive")
    end
  end

  describe 'create_coupon' do
    it 'can create a coupon' do
      params = {name: "Coupon 1", merchant_id: "#{@merchant1.id}", status: "active", code: "CREATECOUP", off: 5, percent_or_dollar: "percent"}
      Coupon.create_coupon(params)
    end

    it 'cannot create a coupon if the merchant has 5 active coupons' do
      coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "active", code: "COUP2", off: 5, percent_or_dollar: "percent")
      coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant1.id, status: "active", code: "COUP3", off: 5, percent_or_dollar: "percent")
      coupon4 = Coupon.create!(name: "Coupon 4", merchant_id: @merchant1.id, status: "active", code: "COUP4", off: 5, percent_or_dollar: "percent")
      coupon5 = Coupon.create!(name: "Coupon 5", merchant_id: @merchant1.id, status: "active", code: "COUP5", off: 5, percent_or_dollar: "percent")

      params = {name: "Coupon 1", merchant_id: "#{@merchant1.id}", status: "active", code: "COUPERROR", off: 5, percent_or_dollar: "percent"}
      
      expect{ Coupon.create_coupon(params) }.to raise_error(FiveActiveCouponsError)
    end

    it 'cannot create a coupon if the merchant does not exist' do
      missing_id = @merchant1.id
      @merchant1.destroy
      params = {name: "Coupon 1", merchant_id: "#{missing_id}", status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent"}
      
      expect{ Coupon.create_coupon(params) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    xit 'cannot create a coupon with a duplicate coupon code' do
      
    end
  end

  describe 'find_coupons' do
    before :each do
      @coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "active", code: "COUP2", off: 5, percent_or_dollar: "percent")
      @coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant1.id, status: "inactive", code: "COUP3", off: 5, percent_or_dollar: "percent")
    end

    it 'can return only active coupons' do
      params = {merchant_id: @merchant1.id, status: "active"}
      coupons = Coupon.find_coupons(params)
      
      expect(coupons.count).to eq(2)
      expect(coupons[0].id).to eq(@coupon1.id)
      expect(coupons[1].id).to eq(@coupon2.id)
    end

    it 'can return only inactive coupons' do
      params = {merchant_id: @merchant1.id, status: "inactive"}
      coupons = Coupon.find_coupons(params)
      
      expect(coupons.count).to eq(1)
      expect(coupons[0].id).to eq(@coupon3.id)
    end

    it 'does not error if there are no active coupons' do
      @coupon1.deactivate
      @coupon2.deactivate
    
      params = {merchant_id: @merchant1.id, status: "active"}
      coupons = Coupon.find_coupons(params)
      
      expect(coupons).to eq([])
    end

    it 'does not error if there are no inactive coupons' do
      @coupon3.activate
    
      params = {merchant_id: @merchant1.id, status: "inactive"}
      coupons = Coupon.find_coupons(params)
      
      expect(coupons).to eq([])
    end

    it 'errors if the merchant does not exist' do
      missing_id = @merchant1.id
      @merchant1.destroy

      params = {merchant_id: missing_id, status: "inactive"}
      
      expect{ Coupon.find_coupons(params) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns all coupons when status is not passed as a parameter' do
      params = {merchant_id: @merchant1.id}
      coupons = Coupon.find_coupons(params)
      
      expect(coupons.count).to eq(3)
      expect(coupons[0].id).to eq(@coupon1.id)
      expect(coupons[1].id).to eq(@coupon2.id)
      expect(coupons[2].id).to eq(@coupon3.id)
    end
  end
end