namespace :gengo do
  desc "Order translations"
  task translate: :environment do
    if Rails.env.development?
      gengo = GENGO_SANDBOX
    else
      gengo = GENGO
    end

    language_jobs = build_jobs
    language_jobs.each do |jobs|
      puts gengo.postTranslationJobs({jobs: jobs})
    end

  end

  def build_jobs
    languages = LANGUAGES
    language_jobs = []

    languages.each do |language|
      job = build_job_for(language)
      language_jobs << job
    end
    language_jobs
  end
end

def build_job_for(language)
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
  # jobs["as_group"] = 1
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

