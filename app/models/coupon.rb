class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  def count_invoices
    invoices.count
  end

  def deactivate
    pending_invoices = Invoice.where("coupon_id = ? AND status = 'pending'", self.id)
    if pending_invoices.count == 0
      self.update!(status: "inactive")
    else 
      raise CouponDeactivationError, "This coupon applies to pending invoices"
    end
  end

  def activate
    activeCoupons = Coupon.where("merchant_id = ?", self.merchant_id)
    if activeCoupons.count < 5
      self.update!(status: "active")
    else 
      raise FiveActiveCouponsError, "Merchant #{self.merchant_id} already has 5 active coupons"
    end
  end

  def self.create_coupon(params)
    merchant = Merchant.find(params[:merchant_id])
    activeCoupons = Coupon.where("merchant_id = ?", params[:merchant_id])
    if activeCoupons.count < 5
      coupon = Coupon.create!(params)
    else
      raise FiveActiveCouponsError, "Merchant #{params[:merchant_id]} already has 5 active coupons"
    end
  end

  def self.find_coupons(params)
    merchant = Merchant.find(params[:merchant_id])
    if params[:status].present?
      Coupon.where("merchant_id = ? AND status = ?", merchant.id, params[:status])
    else
      Coupon.where("merchant_id = ?", merchant.id)
    end
  end
end