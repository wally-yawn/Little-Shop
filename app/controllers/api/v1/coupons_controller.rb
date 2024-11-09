class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_response

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon)
  end

  def create
    coupon = Coupon.create!(coupon_params)
    render json: CouponSerializer.new(coupon), status: 201
  end

  private 
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: 404
  end  

  def invalid_record_response(exception)
    render json: ErrorSerializer.format_error(exception, "400"), status: 400
  end

  def coupon_params
    params.require(:coupon).permit(:merchant_id, :status, :name, :code, :off, :percent_or_dollar)
  end
end