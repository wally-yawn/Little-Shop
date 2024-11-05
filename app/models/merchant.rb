class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :items, dependent: :destroy

  def self.queried(params)
    merchants = Merchant.all
    merchants = Merchant.sort(params)
    merchants = params[:count] == 'true' ? Merchant.with_item_count : merchants
    merchants
  end

  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
    else
      Merchant.all
    end
  end

  def self.with_item_count
      select("merchants.*, COUNT(items.id) AS item_count")
        .left_joins(:items)
        .group("merchants.id")
        
  end
end

