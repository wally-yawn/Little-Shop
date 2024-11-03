class Api::V1::InvoicesController < ApplicationController
  def index
    if params[:merchant_id]
      merchant = Merchant.find_by(id: params[:merchant_id])
      if merchant.nil?
        render json: { error: "Merchant not found" }, status: :not_found
        return
      end
      invoices = Invoice.by_merchant(params[:merchant_id])
    elsif params[:customer_id]
      customer = Customer.find_by(id: params[:customer_id])
      if customer.nil?
        render json: { error: "Customer not found" }, status: :not_found
        return
      end
      invoices = Invoice.by_customer(params[:customer_id])
    else
      invoices = Invoice.all
    end
    render json: InvoiceSerializer.format_invoices(invoices)
  end

    
  def create
    merchant_id = params[:merchant_id]
    unless Invoice.valid_merchant?(merchant_id)
      render json: { error: "Merchant not found" }, status: :not_found and return
    end

    invoice = Invoice.new(invoice_params.merge(merchant_id: merchant_id))
    if invoice.customer_id.nil?
      render json: { errors: ["Customer must exist"] }, status: :unprocessable_entity and return
    end

    if invoice.save
      render json: InvoiceSerializer.format_invoice(invoice), status: :created
    else
      render json: { errors: invoice.errors.full_messages }, status: :unprocessable_entity
    end
  end    
      
  private
  def invoice_params
    params.require(:invoice).permit(:status, :merchant_id, :customer_id)
  end 
 end