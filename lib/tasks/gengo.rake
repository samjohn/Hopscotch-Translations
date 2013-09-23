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
      # puts gengo.postTranslationJobs({jobs: jobs})
    end

  end
  def build_jobs
    languages = LANGUAGES
    language_jobs = []

    languages.each do |language|
      puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      puts language
      jobs = {}

      word_hash_array = []
      EnglishWord.all.each do |english_word|
        translation = english_word.foreign_words.where("language = ?", language).first
        if !translation
          word_hash_array << { "word" => english_word.translatable_string, "comment" => english_word.comment}
        end
      end

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
      jobs["as_group"] = 1
      puts word_hash_array.count
      language_jobs << jobs
    end
    language_jobs
  end
end

