class Invoice < ApplicationRecord
  belongs_to :merchant, :customer
  has_many :transactions, :invoice_items
end