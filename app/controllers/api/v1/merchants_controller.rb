class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.sort(params)
    render json: MerchantSerializer.new(merchants)
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update(merchant_params)
    render json:MerchantSerializer.new(merchant)
  end

  private

  def merchant_params
    params.permit(:name)
  end

  def show
    begin
      render json: MerchantSerializer.format_merchant(Merchant.find(params[:id]))
    rescue ActiveRecord::RecordNotFound => error
      render json: {
        errors: [
          {
            status: "422",
            message: error.message
          }
        ]
      }, status: :not_found
    end
  end
end