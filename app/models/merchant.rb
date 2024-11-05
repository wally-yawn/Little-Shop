class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices
  has_many :items, dependent: :destroy
  has_many :customers

  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
    elsif params[:status] == "returned"
      Merchant.joins(:invoices).where("invoices.status = 'returned'")
    else
      Merchant.all
    end
  end
end