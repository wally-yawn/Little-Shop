class Item < ApplicationRecord
  has_many :invoice_items
  belongs_to :merchant

  def self.sort_by_price
    order(:unit_price)
  end
end