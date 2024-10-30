class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.sort(params)
    render json: MerchantSerializer.format_merchants(merchants)
  end
end