class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.sort(params)
    render json: MerchantSerializer.format_merchants(merchants)
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update(merchant_params)
    render json:MerchantSerializer.format_merchants([merchant])
  end

  private

  def merchant_params
    params.permit(:name)
  end
end