require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe "relationships" do
    it { should have_many(:invoices)}
    it { should belong_to(:merchant)}
  end

  before :each do
    Merchant.destroy_all
    Customer.destroy_all
    Invoice.destroy_all
    Coupon.destroy_all
    @merchant1 = Merchant.create!(name: Faker::Name.unique.name)
    @merchant2 = Merchant.create!(name: Faker::Name.unique.name)
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
      coupon1 = Coupon.create_coupon(params)
      expect(coupon1.name).to eq("Coupon 1")
      expect(coupon1.merchant).to eq(@merchant1)
      expect(coupon1.status).to eq("active")
      expect(coupon1.code).to eq("CREATECOUP")
      expect(coupon1.off).to eq(5)
      expect(coupon1.percent_or_dollar).to eq("percent")
    end

    it 'cannot create a coupon if the merchant has 5 active coupons' do
      coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "active", code: "COUP2", off: 5, percent_or_dollar: "percent")
      coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant1.id, status: "active", code: "COUP3", off: 5, percent_or_dollar: "percent")
      coupon4 = Coupon.create!(name: "Coupon 4", merchant_id: @merchant1.id, status: "active", code: "COUP4", off: 5, percent_or_dollar: "percent")
      coupon5 = Coupon.create!(name: "Coupon 5", merchant_id: @merchant1.id, status: "active", code: "COUP5", off: 5, percent_or_dollar: "percent")

      params = {name: "Coupon 1", merchant_id: "#{@merchant1.id}", status: "active", code: "COUPERROR", off: 5, percent_or_dollar: "percent"}
      
      expect{ Coupon.create_coupon(params) }.to raise_error(FiveActiveCouponsError)
    end

    it 'allows creating an inactive coupon if the merchant has 5 active coupons' do
      coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant1.id, status: "active", code: "COUP2", off: 5, percent_or_dollar: "percent")
      coupon3 = Coupon.create!(name: "Coupon 3", merchant_id: @merchant1.id, status: "active", code: "COUP3", off: 5, percent_or_dollar: "percent")
      coupon4 = Coupon.create!(name: "Coupon 4", merchant_id: @merchant1.id, status: "active", code: "COUP4", off: 5, percent_or_dollar: "percent")
      coupon5 = Coupon.create!(name: "Coupon 5", merchant_id: @merchant1.id, status: "active", code: "COUP5", off: 5, percent_or_dollar: "percent")

      params = {name: "Coupon 6", merchant_id: "#{@merchant1.id}", status: "inactive", code: "COUP6", off: 5, percent_or_dollar: "percent"}
      coupon6 = Coupon.create_coupon(params)
      expect(coupon6.name).to eq("Coupon 6")
      expect(coupon6.merchant).to eq(@merchant1)
      expect(coupon6.status).to eq("inactive")
      expect(coupon6.code).to eq("COUP6")
      expect(coupon6.off).to eq(5)
      expect(coupon6.percent_or_dollar).to eq("percent")
    end

    it 'cannot create a coupon if the merchant does not exist' do
      missing_id = @merchant1.id
      @merchant1.destroy
      params = {name: "Coupon 1", merchant_id: "#{missing_id}", status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent"}
      
      expect{ Coupon.create_coupon(params) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'cannot create a coupon with a duplicate coupon code' do
      params1 = {name: "Coupon 1", merchant_id: "#{@merchant1.id}", status: "active", code: "ALREADYUSED", off: 5, percent_or_dollar: "percent"}
      params2 = {name: "Coupon 2", merchant_id: "#{@merchant1.id}", status: "active", code: "ALREADYUSED", off: 5, percent_or_dollar: "percent"}
      coupon_orig = Coupon.create_coupon(params1)
      expect{ Coupon.create_coupon(params2) }.to raise_error(ActiveRecord::RecordNotUnique)
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
      coupons = Coupon.find_coupons(params).order(:id)
      expect(coupons.count).to eq(3)
      expect(coupons[0].id).to eq(@coupon1.id)
      expect(coupons[1].id).to eq(@coupon2.id)
      expect(coupons[2].id).to eq(@coupon3.id)
    end
  end
end