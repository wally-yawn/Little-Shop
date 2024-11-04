class ErrorSerializer
  include JSONAPI::Serializer
  def self.format_error(exception, status)
    {
      message: "your request could not be completed",
      errors: [
        {
          status: status,
          title: exception.message
        }
      ]
    }
  end
end