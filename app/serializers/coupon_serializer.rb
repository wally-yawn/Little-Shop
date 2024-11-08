class CouponSerializer
  include JSONAPI::Serializer 
  attributes :name, :status, :name, :code, :off, :percent_or_dollar

end