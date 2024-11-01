class Item < ApplicationRecord
  has_many :invoice_items
  belongs_to :merchant

  def self.getItems(params = {})
    #change this to a generic method that uses some if logic to call helper methods
    if params[:sorted] == 'price'
      order(:unit_price)
    else
      Item.all
    end
  end
end