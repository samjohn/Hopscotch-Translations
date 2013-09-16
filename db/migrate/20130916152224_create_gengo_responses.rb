class CreateGengoResponses < ActiveRecord::Migration
  def change
    create_table :gengo_responses do |t|
      t.text :resp_text

      t.timestamps
    end
  end
end
