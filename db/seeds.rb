require 'open-uri'
ForeignWord.delete_all_app_strings
EnglishWord.delete_all_app_strings
file_root_url = "https://s3.amazonaws.com/hopscotchtranslations/#{Rails.env}/en.lproj"

encoding = ENCODING

# create English Words

english_words = EnglishWord.words_from_file_url(file_root_url, encoding)

english_words.each do |line|
  next if line.length == 0

  EnglishWord.create_word_from_line(line)
end

#create words for other languages
languages = LANGUAGES

languages.each do |language|
  language_words = ForeignWord.get_words_for_language(language, file_root_url, encoding)

  language_words.each do |line|
    next if line.length == 0

    ForeignWord.create_foreign_word_from_data(line, language)
  end
end

EnglishWord.create_foreign_words
