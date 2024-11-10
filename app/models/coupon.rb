class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  def count_invoices
    invoices.count
  end
end
