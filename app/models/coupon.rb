class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  def countInvoices
    invoices.count
  end
end
