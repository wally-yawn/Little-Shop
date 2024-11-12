class Api::V1::InvoicesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  # rescue_from CouponAndInvoiceMerchantMismatchError, with: :coupon_invoice_merchant_mismatch

  def index
    invoices = Invoice.filter(params)
    render json: InvoiceSerializer.format_invoices(invoices)
  end
      
  private
  
  # def invoice_params
  #   params.require(:invoice).permit(:status, :merchant_id, :customer_id)
  # end 

  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end  

  # def coupon_invoice_merchant_mismatch(exception)
  #   render json: ErrorSerializer.format_error(exception, "422"), status: 422
  # end  
end