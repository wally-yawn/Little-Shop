class Merchant < ApplicationRecord
  has_many :items

  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
    else
      Merchant.all
    end
  end
end