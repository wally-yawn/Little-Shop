class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.all
    render json: items
  end  

  def show
    item = Item.find(params[:id])
    render json: item, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end  
end
