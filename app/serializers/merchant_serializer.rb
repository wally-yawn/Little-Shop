class MerchantSerializer

  def self.format_merchants(merchants)
    merchant_data = merchants.map do |merchant|
      {
        id: merchant.id,
        type: "merchant",
        attributes: {
          name: merchant.name
        }
      }
    end
    {data: merchant_data}
  end
end