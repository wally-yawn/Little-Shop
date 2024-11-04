class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    items = Item.getItems(params)
    if items.is_a?(String)
      render json: {"message": "your query could not be completed", "errors": ["#{items}"]}, status: 404
    else
      render json: ItemSerializer.format_items(items)
    end
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.format_single_item(item)
  end
  
  private
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end  

  def destroy
    begin
      item = Item.find(params[:id])
      item.destroy
    rescue ActiveRecord::RecordNotFound => error
      render json: {"message": "your query could not be completed", "errors": ["#{error}"]}, status: 404
    end
  end
end