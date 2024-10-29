class API::V1::PostersController < ApplicationController

  def index
    render json: MerchantSerializer.format_merchants(Merchant.all)
  end
end