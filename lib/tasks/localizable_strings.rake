namespace :localizable_strings do
  desc "Write translation files"
  task write: :environment do
    languages = LANGUAGES

    languages.each do |language|
      transloadit = Transloadit.new(
        :key    => TRANSLOADIT_KEY,
        :secret => TRANSLOADIT_SECRET
      )

      timestamp = Time.now.strftime("%m-%d-%Y")
      language_path = LANGUAGE_FOLDER_MAPPINGS[language]
      path = "#{Rails.env}/en.lproj/#{language_path}.lproj/Localizable.strings"
      store  = transloadit.step("store", "/s3/store",
                                :key    => AWS_KEY,
                                :secret => AWS_SECRET,
                                :bucket => AWS_BUCKET,
                                :path   => path )
      assembly = transloadit.assembly(:steps => [store])


      ForeignWord.write_file_for_language(language)

      response = assembly.submit! open(Rails.root.join("tmp/#{language}/Localizable.strings"))

      until response.finished?
        sleep 1; response.reload! # you'll want to implement a timeout in your production app
      end
      puts response
    end


  end
end
