class GengoOrder < ActiveRecord::Base
  validates_uniqueness_of :order_id
  has_many :gengo_jobs, primary_key: :order_id, foreign_key: :order_id

  def create_jobs_from_gengo(gengo)
    resp = gengo.getTranslationOrderJobs(order_id: order_id)

    available_job_ids = resp["response"]["order"]["jobs_available"]
    available_job_ids.each do |job_id|
      update_or_create_job_with_id_and_status(job_id, GengoJob::STATUS_AVAILABLE)
    end

    approved_job_ids = resp["response"]["order"]["jobs_approved"]
    approved_job_ids.each do |job_id|
      update_or_create_job_with_id_and_status(job_id, GengoJob::STATUS_APPROVED)
    end
  end

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
