class MerchantSerializer
  include JSONAPI::Serializer 
  attributes :name, :coupons_count, :invoice_coupon_count

  def self.format_with_item_count(merchants)
    {
      data: merchants.map do |merchant|
        {
          id: merchant.id.to_s,
          type: "merchant",
          attributes: {
            name: merchant.name,
            item_count: merchant.item_count,
            coupons_count: merchant.coupons_count, 
            invoice_coupon_count: merchant.invoice_coupon_count
          }
        }
      end
    }
  end
end