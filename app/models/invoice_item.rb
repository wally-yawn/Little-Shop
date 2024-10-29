class Invoice_items < ApplicationRecord
  belongs_to :items, :invoices
end