class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon)
  end

  private 
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end  

  def coupon_params
    params.require(:merchant_id).permit(:status, :name, :code, :off, :percent_or_dollar)
  end

end