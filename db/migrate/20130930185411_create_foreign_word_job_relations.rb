class CreateForeignWordJobRelations < ActiveRecord::Migration
  def change
    create_table :foreign_word_job_relations do |t|
      add_column :gengo_jobs, :foreign_word_id, :integer
    end
  end
end
