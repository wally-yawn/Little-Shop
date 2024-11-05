class Item < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true
  validates :merchant_id, presence: true
  has_many :invoice_items, dependent: :destroy
  belongs_to :merchant

  def self.getItems(params = {})
    if params[:sorted] == 'price'
      Item.all.order(:unit_price)
    elsif params.key?(:id)
      begin
        merchant = Merchant.find(params[:id])
        Item.all.where("merchant_id = #{merchant.id}")
      rescue ActiveRecord::RecordNotFound => error
        error.message
      end
    else
      Item.all
    end
  end
end