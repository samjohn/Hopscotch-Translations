EnglishWord.delete_all
ForeignWord.delete_all
file_root = "/Users/samanthajohn/Dropbox/Hopscotch/Translations/localizable_strings/en.lproj"
encoding = "rb:UTF-16LE"

#create English Words
en_file_path = "#{file_root}/Localizable.strings"
en_file = File.open(en_file_path, encoding)
english_words = en_file.read.split("\n\n")

english_words.each do |word|
  split_word = word.split("*")
  comment = split_word[1]
  english = split_word[2].split("\"")[1]

  e = EnglishWord.new(comment: comment, translatable_string: english)
  if (e.valid?)
    e.save
  else
    puts "English: #{english} #{e.errors.full_messages}"
  end
end

#create words for other languages
languages = %w(cs da de el es fr ja ko nl pt ru sv zh zh-tw)
language_folder_mappings = {"zh" => "zh-Hans", "zh-tw" => "zh-Hant"}

languages.each do |language|
  language_folder = language_folder_mappings[language] || language
  language_file_path = "#{file_root}/#{language_folder}.lproj/Localizable.strings"
  language_file = File.open(language_file_path, encoding)

  language_words = language_file.read.split("\n")

  language_words.each do |word|
    if (word.length > 0)
      split_word = word.split("\"")
      english = split_word[1]
      translation = split_word[3]
      f = ForeignWord.new(translatable_string: english,
                         language: language,
                         translated_string: translation)
      if (f.valid?)
        f.save
      else
        puts "#{language}, #{english} #{f.errors.full_messages}"
      end
    end
  end
end

