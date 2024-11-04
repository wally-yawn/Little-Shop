class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :items, dependent: :destroy

  def self.queried(params)
    merchants = Merchant.all
    merchants = Merchant.sort(params)
    merchants = Merchant.item_count(merchants, params[:count])
    merchants
  end

  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
    else
      Merchant.all
    end
  end

  def self.item_count(merchants, count_param)
    if count_param == 'true'
      merchants.select("merchants.*, COUNT(items.id) AS item_count")
        .left_joins(:items)
        .group("merchants.id")
    else
      merchants
    end
  end
end

