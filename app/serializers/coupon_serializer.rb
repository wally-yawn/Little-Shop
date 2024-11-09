class CouponSerializer
  include JSONAPI::Serializer 
  attributes :name, :merchant_id, :status, :code, :off, :percent_or_dollar

end