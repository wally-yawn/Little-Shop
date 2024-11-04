class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    items = Item.sort_by_price(params[:sorted])
    render json: ItemSerializer.format_items(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.format_single_item(item)
  end
  
  private
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end
end