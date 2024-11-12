require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { should belong_to(:customer) }
    it { should belong_to(:merchant) }
    it { should have_many(:transactions)}
    it { should have_many(:invoice_items)}
    it { should belong_to(:coupon).optional}
  end

  describe 'custom validation' do
    it 'validates that the coupon and invoice merchant_id match' do
      @merchant = Merchant.create!(name: "Merchant A")
      @other_merchant = Merchant.create!(name: "Merchant B")
      @customer = Customer.create!(first_name: "Lisa", last_name: "Reeve")
      @coupon1 = Coupon.create!(name: "Coupon 1", merchant: @merchant, status: "active", code: Faker::Games::Pokemon.unique.name, off: 10, percent_or_dollar: "percent")
      
      expect { @invoice1 = Invoice.create!(coupon: @coupon1, customer: @customer, merchant: @other_merchant, status: "completed") }.to raise_error(CouponAndInvoiceMerchantMismatchError)
    end
  end

  describe 'class methods' do
    before(:each) do
      Invoice.destroy_all
      @merchant = Merchant.create!(name: "Merchant A")
      @other_merchant = Merchant.create!(name: "Merchant B")
      @customer = Customer.create!(first_name: "Lisa", last_name: "Reeve")
      @invoice1 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed")
      @invoice2 = Invoice.create!(customer: @customer, merchant: @merchant, status: "pending")
      @invoice3 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed")
      @other_invoice = Invoice.create!(customer: @customer, merchant: @other_merchant, status: "completed")
    end

    describe 'calculate_total' do
      before :each do
        @item1 = Item.create!(name: Faker::Games::Pokemon.name, description: 'description', unit_price: 1.99, merchant_id: @merchant.id)
        @item2 = Item.create!(name: Faker::Games::Pokemon.name, description: 'description', unit_price: 3.99, merchant_id: @merchant.id)
        @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: 4.49)
        @invoice_item2 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 10, unit_price: 6.49)
      end

      it 'can calculate the total value of an invoice' do
        expect(@invoice1.calculate_total).to eq(69.39)
      end

      it 'can calculate the total value when there are no invoice items' do
        expect(@invoice2.calculate_total).to eq(0)
      end

      it 'can calculate the total value of an invoice and ignore coupons' do
        @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
        @invoice1.coupon = @coupon1
        expect(@invoice1.calculate_total).to eq(69.39)
      end
    end

    describe 'calculate_discounted_total' do
      before :each do
        @item1 = Item.create!(name: "item1", description: 'description', unit_price: 1.99, merchant_id: @merchant.id)
        @item2 = Item.create!(name: "item2", description: 'description', unit_price: 3.99, merchant_id: @merchant.id)
        @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: 4.49)
        @invoice_item2 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 10, unit_price: 6.49)
        @coupon1 = Coupon.create!(name: "Coupon 1", merchant_id: @merchant.id, status: "active", code: Faker::Games::Pokemon.unique.name, off: 10, percent_or_dollar: "percent")
        @coupon2 = Coupon.create!(name: "Coupon 2", merchant_id: @merchant.id, status: "active", code: Faker::Games::Pokemon.unique.name, off: 10, percent_or_dollar: "dollar")
      end

      it 'can calculate the discounted total on an invoice with a % coupon' do
        @invoice1.coupon = @coupon1
        expect(@invoice1.calculate_discounted_total).to eq(62.45)
      end

      it 'can calculate the discounted total on an invoice with a $ coupon' do
        @invoice1.coupon = @coupon2
        expect(@invoice1.calculate_discounted_total).to eq(59.39)
      end

      it 'can calculate the discounted total on an invoice without a coupon' do
        expect(@invoice1.calculate_total).to eq(69.39)
      end

      it 'can calculate the discounted total on an invoice with a coupon with no items' do
        @invoice2.coupon = @coupon1
        expect(@invoice2.calculate_discounted_total).to eq(0)
      end

      it 'does not allow the total to go below 0 with a dollar coupon' do
        @coupon2.off = 100
        @invoice1.coupon = @coupon2
        expect(@invoice1.calculate_discounted_total).to eq(0)
      end
    end

    describe 'filter' do
      it 'returns filtered based on merchant' do
        invoices = Invoice.filter({merchant_id: @merchant.id})
        expect(invoices).to eq([@invoice1, @invoice2, @invoice3])
      end

      it 'returns filtered based on merchant and status' do
        invoices = Invoice.filter({merchant_id: @merchant.id, status: "completed"})
        expect(invoices).to eq([@invoice1, @invoice3])
      end

      it 'returns an empty array when no invoices exist' do
        other_merchant2 = Merchant.create!(name: "Merchant C")
        invoices = Invoice.filter({merchant_id: other_merchant2.id})
        expect(invoices).to eq([])
      end
    end
    
    describe 'optional coupon parameter' do
      it 'can add an optional coupon_id' do
        coupon = Coupon.create!(name: "Coupon 1", merchant_id: @merchant.id, status: "active", code: "COUP1", off: 5, percent_or_dollar: "percent")
        invoice4 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed", coupon: coupon)

        expect(invoice4.coupon_id).to eq(coupon.id)
      end
    end
  end
end