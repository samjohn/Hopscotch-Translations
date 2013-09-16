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
      puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    end

  end
  def build_jobs
    languages = %w(ja zh da el es fr ko nl pt ru sv cs de he)
    language_jobs = []
    word_hash_array = [
      {"word" => "hello world", "comment" => "foo bar"},
      {"word" => "goodbye heaven", "comment" => "all good dogs go to heaven"}
       }
    ]

    languages.each do |language|
      jobs = {}
      word_hash_array.each_with_index do |word, index|
        jobs["job_#{index + 1}"] = {
          type: "text",
          slug: language,
          comment: word["comment"],
          body_src: word["word"],
          lc_src: "en",
          lc_tgt: language,
          tier: "standard"
        }
      end
      jobs["as_group"] = 1
      language_jobs << jobs
    end
    language_jobs
  end
end

