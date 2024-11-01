class Item < ApplicationRecord
  has_many :invoice_items
  belongs_to :merchant

  def self.sort_by_price(sort_order = nil)
    if sort_order == 'price'
      order(:unit_price)
    else
      Item.all
    end
  end
end