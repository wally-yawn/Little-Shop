class ItemSerializer
    include JSONAPI::Serializer 
    attributes :name, :description, :unit_price, :merchant_id
    
    def self.format_items(items)
        { data: items.map { |item| formatted_item(item) }}
    end

    def self.format_single_item(item)
        { data: formatted_item(item) }
    end

    def self.formatted_item(item)
        {
            id: "#{item.id}",
            type: "item",
            attributes: {
                name: item.name,
                description: item.description,
                unit_price: item.unit_price,
                merchant_id: item.merchant_id
            }
        }
    end
end