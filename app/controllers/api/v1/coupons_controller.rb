class Api::V1::CouponController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def show
    coupon = Coupon.find(params[:id])
    render json: CustomerSerializer.format_customer(customer)
  end

  private 
  def not_found_response
    render json: { message: "Resource not found" }, status: :not_found
  end

  def coupon_params
    params.require(:merchant_id).permit(:status, :name, :code, :off, :percent_or_dollar)
  end

end