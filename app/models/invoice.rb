class Invoices < ApplicationRecord
  belongs_to :merchants, :customers
  has_many :transactions, :invoice_items
end