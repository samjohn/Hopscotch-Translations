class GengoOrder < ActiveRecord::Base
  validates_uniqueness_of :order_id
  has_many :gengo_jobs, primary_key: :order_id, foreign_key: :order_id
end
