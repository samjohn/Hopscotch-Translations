namespace :gengo do
  desc "Order translations"
  task translate: :environment do
    file_path = Rails.root.join("lib", "files", "file.txt").to_s
    GENGO.getTranslationQuote({
      :jobs => {
        :job_1 => {
          :type => "file",
          :slug => "Hallo",
          :lc_src => "fr",
          :lc_tgt => "en",
          :tier => "standard",
          :file_path => file_path
        }
      },
      :is_upload => true
    })
  end

end
