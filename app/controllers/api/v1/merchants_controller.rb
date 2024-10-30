class Api::V1::MerchantsController < ApplicationController

  def index
    render json: MerchantSerializer.format_merchants(Merchant.all)
  end

  
end