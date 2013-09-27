class GengoOrder < ActiveRecord::Base
  validates_uniqueness_of :order_id
  has_many :gengo_jobs, primary_key: :order_id, foreign_key: :order_id

  def update_or_create_job_with_id_and_status(job_id, status)
    job = self.gengo_jobs.where("job_id=?", job_id).first
    job ||= self.gengo_jobs.build(job_id: job_id)
    job.status = status
    if (job.valid?)
      job.save
    else
      puts job.errors.full_messages
    end
  end
end
