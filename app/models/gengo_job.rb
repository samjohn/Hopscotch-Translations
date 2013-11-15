class GengoJob < ActiveRecord::Base
  STATUS_AVAILABLE = "available"
  STATUS_APPROVED = "approved"
  validates_uniqueness_of :job_id
  scope :approved, -> { where(status: STATUS_APPROVED) }
  scope :available, -> { where("status != ?", STATUS_APPROVED) }
  scope :unsynced, -> { where(completed: false) }
  scope :locally_unsynced, -> { where("foreign_word_id IS NULL") }

  belongs_to :foreign_word

  def complete_if_approved!
    if status == STATUS_APPROVED
      completed = true
    end
    save!
  end

  def sync_with_foreign_word(gengo)
    useful_response = sync_with_gengo(gengo)
    self.status = useful_response["status"]
    language = useful_response["lc_tgt"]
    translatable_string = useful_response["body_src"]
    translated_string = useful_response["body_tgt"]

    foreign_word = ForeignWord.where(language: language,
                                     translatable_string: translatable_string).first

    foreign_word ||= self.build_foreign_word(language: language,
                                                  translatable_string: translatable_string)

    foreign_word.translated_string = translated_string
    self.foreign_word = foreign_word
    self.completed = self.status == GengoJob::STATUS_APPROVED
    self.foreign_word.save
    puts "#{translatable_string} translated for #{language}"
    save
  end

  def sync_with_gengo(gengo)
    resp = gengo.getTranslationJob(id: job_id)
    useful_response = resp["response"]["job"]
  end

  def sync_with_gengo_and_foreign_word(gengo)
    useful_response = sync_with_gengo(gengo)
    self.status = useful_response["status"]
    language = useful_response["lc_tgt"]
    translatable_string = useful_response["body_src"]
    translated_string = useful_response["body_tgt"]

    self.foreign_word = ForeignWord.where(language: language,
                                     translatable_string: translatable_string).first

    self.foreign_word ||= self.build_foreign_word(language: language,
                                                  translatable_string: translatable_string)
    self.foreign_word.translated_string = translated_string
    self.completed = self.status == GengoJob::STATUS_APPROVED
    save
  end
end
