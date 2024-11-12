class Api::V1::InvoicesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response


  def index
    invoices = Invoice.filter(params)
    render json: InvoiceSerializer.format_invoices(invoices)
  end
      
  private
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end  
end