class Api::V1::MerchantCouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  # rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_response

  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = Coupon.where("merchant_id = ?", merchant.id)
    render json: CouponSerializer.new(coupons)
  end

  private 
  
  def not_found_response(exception = "Record not found")
    render json: { message: "your request could not be completed", errors: [exception.to_s] }, status: :not_found
  end

  def invalid_record_response(exception)
    render json: { message: "your request could not be completed", errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def error_messages(messages, status)
    {
      message: "your request could not be completed",
      errors: messages,
      status: status
    }
  end
end