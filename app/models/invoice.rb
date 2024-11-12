class Invoice < ApplicationRecord
  belongs_to :merchant
  belongs_to :customer
  belongs_to :coupon, optional: :true
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy

  before_validation :set_default_status

  validates :merchant, :customer, :status, presence: true

  def self.filter(params)
    merchant = Merchant.find(params[:merchant_id])
    if params.include?(:status)
      invoices = Invoice.where(merchant_id: params[:merchant_id], status: params[:status])
    else 
      invoices = Invoice.where(merchant_id: params[:merchant_id])
    end
  end

  def calculate_total
    invoice_total = 0
    self.invoice_items.each do |invoice_item|
      invoice_total += invoice_item.quantity * invoice_item.unit_price
    end
    invoice_total
  end

  def calculate_discounted_total
    invoice_total = calculate_total
    if (self.coupon_id != nil && self.coupon.percent_or_dollar == "percent")
      invoice_total = (invoice_total * (1 - (coupon.off/ 100))).round(2)
    elsif(self.coupon_id != nil && self.coupon.percent_or_dollar == "dollar")
      invoice_total -= coupon.off
    end
    if invoice_total < 0
      0
    else
      invoice_total
    end
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end
  
end