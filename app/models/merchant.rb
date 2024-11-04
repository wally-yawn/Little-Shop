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

  def self.getId(params)
    if params[:item_id]
      item = Item.find_by(id: params[:item_id])
      item.merchant
    else
      Merchant.find(params[:id])
    end
  end
end