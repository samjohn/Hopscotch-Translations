class GengoJob < ActiveRecord::Base
  STATUS_AVAILABLE = "available"
  STATUS_APPROVED = "approved"
  validates_uniqueness_of :job_id
  scope :approved, -> { where(status: STATUS_APPROVED) }
  scope :available, -> { where("status != ?", STATUS_APPROVED) }
  scope :unsynced, -> { where(completed: false) }

  belongs_to :foreign_word

  def complete_if_approved!
    if status == STATUS_APPROVED
      completed = true
    end
    save!
  end

  def sync_with_gengo_and_foreign_word(gengo)
    resp = gengo.getTranslationJob(id: job_id)
    useful_response = resp["response"]["job"]
    self.status = useful_response["status"]
    language = useful_response["lc_tgt"]
    translatable_string = useful_response["body_src"]

    self.foreign_word = ForeignWord.where(language: language,
                                     translatable_string: translatable_string).first

    self.foreign_word ||= self.build_foreign_word(language: language,
                                                  translatable_string: translatable_string)
    self.completed = self.status == GengoJob::STATUS_APPROVED
    save
  end
end
