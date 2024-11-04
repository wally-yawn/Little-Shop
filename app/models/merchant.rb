class Merchant < ApplicationRecord
  validates :name, presence: true

  has_many :items

  has_many :items, dependent: :destroy

  has_many :customers



  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
    else
      Merchant.all
    end
  end
end