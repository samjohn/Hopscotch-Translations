class MakeOrderIdsAndJobIdsUnique < ActiveRecord::Migration
  def change
    add_index :gengo_orders, :order_id, unique: true
    add_index :gengo_jobs, :job_id, unique: true

    add_column :gengo_orders, :complete, :boolean
    add_column :gengo_orders, :available_job_count, :integer

    add_column :gengo_jobs, :status, :string

    change_column :gengo_orders, :order_id, :string
    change_column :gengo_jobs, :order_id, :string
    change_column :gengo_jobs, :job_id, :string
  end
end
