class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.bigint :merchant_id, null: false
      t.integer :status
      t.string :name
      t.string :code
      t.float :off
      t.integer :percent_or_dollar

      t.timestamps
    end

    add_foreign_key :coupons, :merchants, column: :merchant_id
  end
end
