class GengoJob < ActiveRecord::Base
  STATUS_AVAILABLE = "available"
  STATUS_APPROVED = "approved"
  validates_uniqueness_of :job_id
  scope :approved, -> { where(status: STATUS_APPROVED) }
  scope :unsynced, -> { where(completed: false) }
end
