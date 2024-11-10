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
      @invoice3 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "pending", coupon: @coupon1)
      expect{ @coupon1.deactivate }.to raise_error(CouponDeactivationError)
      expect(@coupon1.status).to eq("active")
    end

    xit 'cannot deactivate a coupon that is inactive' do

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
      coupon6 = Coupon.create!(name: "Coupon 6", merchant_id: @merchant1.id, status: "active", code: "COUP16", off: 5, percent_or_dollar: "percent")
      expect{ @coupon1.activate }.to raise_error(FiveActiveCouponsError)
      expect(@coupon1.status).to eq("inactive")
    end

    xit 'it cannot activate a coupon if the coupon is already active'
  end

end