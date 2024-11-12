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

  def calculate_total()
    puts 'calculated total'
  end

  def calculate__discounted_total()
    puts 'calculated total'
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end
  
end