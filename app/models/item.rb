class Items < ApplicationRecord
  has_many :invoice_items
  belongs_to :merchant
end