class Api::V1::CustomersController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = Invoice.where(merchant_id: merchant.id)
    customers = invoices.map(&:customer).uniq
    render json: CustomerSerializer.format_customers(customers)
  end
        
  def show
    customer = Customer.find(params[:id])
    render json: CustomerSerializer.format_customer(customer)
  end

  def create 
    customer = Customer.create(customer_params)
    render json: CustomerSerializer.format_customers([customer])
  end
end