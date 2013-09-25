class CreateGengoOrders < ActiveRecord::Migration
  def change
    create_table :gengo_orders do |t|
      t.integer :order_id
      t.timestamps
    end
  end
end
