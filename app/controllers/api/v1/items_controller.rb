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
return_the_merchant_associated_with_an_item

  def create
    begin
      item = Item.create!(item_params)
      render json: ItemSerializer.new(item), status: 201
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: 422
    end
  end

  def update
    begin
    item = Item.find(params[:id])
    item.update!(item_params)

    render json: ItemSerializer.format_single_item(item)
  rescue ActiveRecord::RecordNotFound => error
    render json: error_messages([error.message], 404), status: 404
  rescue ActiveRecord::RecordInvalid => errors
    render json: error_messages(errors.record.errors.full_messages, 422), status: 422
  end
  end

  def destroy
    begin
      item = Item.find(params[:id])
      item.destroy
    rescue ActiveRecord::RecordNotFound => error
      render json: {"message": "your query could not be completed", "errors": ["#{error}"]}, status: 404
    end
  end
  
  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end  


  def error_messages(messages, status)
    {
      message: "your request could not be completed",
      errors: messages,
      status: status
    }
  end
return_the_merchant_associated_with_an_item
  
  private
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Item not found' }, status: :not_found
  end  


main
end