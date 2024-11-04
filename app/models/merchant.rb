class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :items, dependent: :destroy
  has_many :customers

  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
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
      Merchant.find(params[:id])
    end
  end
end