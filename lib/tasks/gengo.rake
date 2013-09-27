namespace :gengo do
  desc "Order translations"
  task translate: :environment do
    gengo = gengo_for_env
    language_jobs = build_jobs
    language_jobs.each do |jobs|
      resp = gengo.postTranslationJobs({jobs: jobs, as_group: 1})
      order_id = resp["response"]["order_id"]
      job_count = resp["response"]["job_count"]
      order = GengoOrder.create(order_id: order_id, available_job_count: job_count)
    end
  end

  desc "view all orders"
  task view_orders: :environment do
    gengo = gengo_for_env
    orders = GengoOrder.all

    orders.each do |gengo_order|
      resp = gengo.getTranslationOrderJobs(order_id: gengo_order.order_id)
      puts resp["response"]["order"]
    end
  end

  desc "Update or create jobs for all orders"
  task sync_jobs_with_gengo: :environment do
    gengo = gengo_for_env
    orders = GengoOrder.all
    orders.each do |gengo_order|
      resp = gengo.getTranslationOrderJobs(order_id: gengo_order.order_id)

      available_job_ids = resp["response"]["order"]["jobs_available"]
      available_job_ids.each do |job_id|
        gengo_order.update_or_create_job_with_id_and_status(job_id, GengoJob::STATUS_AVAILABLE)
      end

      approved_job_ids = resp["response"]["order"]["jobs_approved"]
      approved_job_ids.each do |job_id|
        gengo_order.update_or_create_job_with_id_and_status(job_id, GengoJob::STATUS_APPROVED)
      end
    end
  end

  desc "Sync words with complete jobs"
  task sync_translations_with_jobs: :environment do
    gengo = gengo_for_env

    jobs = GengoJob.approved.unsynced
    jobs.each do |gengo_job|
      resp = gengo.getTranslationJob(id: gengo_job.job_id)
      useful_response = resp["response"]["job"]

      status = useful_response["status"]
      if status == GengoJob::STATUS_APPROVED
        lang = useful_response["lc_tgt"]
        translatable_string = useful_response["body_src"]
        translated_string = useful_response["body_tgt"]

        f = ForeignWord.new(language: lang, 
                            translatable_string: translatable_string,
                            translated_string: translated_string)
        if f.valid?
          f.save
          gengo_job.update_attribute(:completed, true)
        else
          puts f.errors.full_messages
        end
      else
        puts status
        gengo_job.update_attribute(:status, status)
      end
    end
  end
end

def gengo_for_env
  if Rails.env.development?
    GENGO_SANDBOX
  else
    GENGO
  end
end

def build_jobs
  languages = LANGUAGES
  language_jobs = []

  languages.each do |language|
    job = build_job_for_language(language)
    language_jobs << job
  end
  language_jobs
end

def build_job_for_language(language)
  jobs = {}

  word_hash_array = create_word_hash_for(language)

  word_hash_array.each_with_index do |word, index|
    jobs["job_#{index + 1}"] = {
      type: "text",
      slug: language,
      comment: word["comment"],
      body_src: word["word"],
      lc_src: "en",
      lc_tgt: language,
      tier: "standard",
      auto_approve: 1
    }
  end
  puts "#{language} #{word_hash_array.count}"
  jobs
end

def create_word_hash_for(language)
  word_hash_array = []

  EnglishWord.all.each do |english_word|
    translation = english_word.foreign_words.where("language = ?", language).first
    if !translation
      if (english_word.translatable_string != ".")
        word = english_word.translatable_string
        word_hash_array << { "word" => word, "comment" => english_word.comment}
      end
    end
  end
  word_hash_array
end



