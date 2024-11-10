class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  def count_invoices
    invoices.count
  end

  def deactivate
    pending_invoices = Invoice.where("coupon_id = ? AND status = 'pending'", self.id)
    if pending_invoices.count == 0
      self.update(status: "inactive")
      puts self.errors.full_messages if self.errors.any?
    end
  end
end
