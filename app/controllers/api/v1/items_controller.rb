class Api::V1::ItemsController < ApplicationController
  def index
    items = params[:sorted] == 'price' ? Item.sort_by_price : Item.all
    render json: ItemSerializer.format_items(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.format_single_item(item)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end  
end