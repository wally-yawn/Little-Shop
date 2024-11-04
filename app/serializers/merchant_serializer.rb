class MerchantSerializer

  include JSONAPI::Serializer 
  attributes :name

  attribute :item_count do |merchant|
    merchant.items.count
  end
end

# set_id :id
# set_type :merchant
# attributes :name

# attribute :item_count do |merchant|
#   merchant.items.count
# end
# end