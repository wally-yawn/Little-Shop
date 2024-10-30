class Api::V1::MerchantsController < ApplicationController

  def index
    render json: MerchantSerializer.format_merchants(Merchant.all)
  end

  def show
    render json: MerchantSerializer.format_merchant(Merchant.find(params[:id]))
  end
end