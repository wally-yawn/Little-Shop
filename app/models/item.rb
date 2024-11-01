class Item < ApplicationRecord
  has_many :invoice_items
  belongs_to :merchant

  def self.getItems(params = {})
    #change this to a generic method that uses some if logic to call helper methods
    if params[:sorted] == 'price'
      Item.all.order(:unit_price)
    elsif params.key?(:id)
      merchant = Merchant.find(params[:id])
      Item.all.where("merchant_id = #{merchant.id}")
    else
      Item.all
    end
  end
end