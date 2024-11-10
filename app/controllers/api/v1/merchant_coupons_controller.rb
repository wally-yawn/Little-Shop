class Api::V1::MerchantCouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  # rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_response

  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = Coupon.where("merchant_id = ?", merchant.id)
    render json: CouponSerializer.new(coupons)
  end

  private 
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: 404
  end  

  # def coupon_params
  #   params.require(:merchant_id)
  # end
end