class CreateGengoJobs < ActiveRecord::Migration
  def change
    create_table :gengo_jobs do |t|
      t.integer :job_id
      t.boolean :completed, default: false
      t.integer :order_id
      t.timestamps
    end
  end
end
