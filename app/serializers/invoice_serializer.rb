class InvoiceSerializer
  def self.format_invoices(invoices)
    {
      data: invoices.map do |invoice|
        {
          id: invoice.id.to_s,
          type: 'invoice',
          attributes: {
            customer_id: invoice.customer_id,
            merchant_id: invoice.merchant_id,
            coupon_id: invoice.coupon_id,
            status: invoice.status,
          }
        }
      end
    }
  end

  # def self.format_invoice(invoice)
  #   {
  #     data: {
  #       id: invoice.id.to_s,
  #       type: 'invoice',
  #       attributes: {
  #         customer_id: invoice.customer_id,
  #         merchant_id: invoice.merchant_id,
  #         coupon_id: invoice.coupon_id,
  #         status: invoice.status,
  #       }
  #     }
  #   }
  # end
end