class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_response
  rescue_from CouponDeactivationError, with: :deactivation_error_response
  rescue_from FiveActiveCouponsError, with: :five_active_coupons_error_response
  rescue_from ActiveRecord::RecordNotUnique, with: :non_unique_code_error_response

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon)
  end

  def create
    coupon = Coupon.create_coupon(coupon_params)
    render json: CouponSerializer.new(coupon), status: 201
  end

  def deactivate
    coupon = Coupon.find(params[:id])
    coupon.deactivate
    render json: CouponSerializer.new(coupon)
  end

  def activate
    coupon = Coupon.find(params[:id])
    coupon.activate
    render json: CouponSerializer.new(coupon)
  end

  private 
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: 404
  end

  def deactivation_error_response(exception)
    render json: ErrorSerializer.format_error(exception, "422"), status: 422
  end

  def five_active_coupons_error_response(exception)
    render json: ErrorSerializer.format_error(exception, "422"), status: 422
  end

  def non_unique_code_error_response(exception)
    custom_exception = ActiveRecord::RecordNotUnique.new("That code is already in use")
    render json: ErrorSerializer.format_error(custom_exception, "422"), status: 422
  end

  def coupon_params
    params.require(:coupon).permit(:merchant_id, :status, :name, :code, :off, :percent_or_dollar)
  end
end