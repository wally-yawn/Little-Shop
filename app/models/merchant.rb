class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :coupons, dependent: :destroy
  has_many :customers

  def self.queried(params)
    merchants = Merchant.all
    merchants = Merchant.sort(params)
    merchants = params[:count] == 'true' ? Merchant.with_item_count : merchants
    merchants
  end

  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
    elsif params[:status] == "returned"
      Merchant.joins(:invoices).where("invoices.status = 'returned'")
    else
      Merchant.all
    end
  end

  def self.getMerchant(params)
    if params[:item_id]
      begin
        item = Item.find(params[:item_id])
        item.merchant
      rescue ActiveRecord::RecordNotFound => error
        error.message
      end
    else
      begin
        Merchant.find(params[:id])
      rescue ActiveRecord::RecordNotFound => error
        error.message
      end
    end
  end

  def self.with_item_count
    select("merchants.*, COUNT(items.id) AS item_count")
      .left_joins(:items)
      .group("merchants.id")
  end

  def self.find_by_params(params) #is this redundant with self.getMerchant? Not at 2:48am it isn't but something to look at refactoring
    if params.has_key?(:name) && params[:name].present?
      merchant = Merchant.where('name ILIKE ?', "%#{params[:name]}%").first
      merchant || { error: { message: "No merchant found", status: 404 } }
    else
      { error: { message: "you need to specify a name", status: 404 } }
    end
  end

  def get_coupon_count
    Coupon.where(merchant: self).count
  end

  def get_invoice_coupon_count
    Invoice.where(merchant: self).where.not(coupon_id: nil).count
  end
end