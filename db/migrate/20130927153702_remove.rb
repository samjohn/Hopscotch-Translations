class Remove < ActiveRecord::Migration
  def change
    drop_table :gengo_responses
  end
end
