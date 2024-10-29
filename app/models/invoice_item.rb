class Invoice_item < ApplicationRecord
  belongs_to :item, :invoice
end