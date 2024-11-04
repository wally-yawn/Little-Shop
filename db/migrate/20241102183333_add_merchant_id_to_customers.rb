class AddMerchantIdToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_reference :customers, :merchant, foreign_key: true
  end
end
