EnglishWord.delete_all
ForeignWord.delete_all
file_root = "/Users/samanthajohn/Dropbox/Hopscotch/Translations/localizable_strings/en.lproj"
encoding = "rb:UTF-16LE"

#create English Words
en_file_path = "#{file_root}/Localizable.strings"
en_file = File.open(en_file_path, encoding)
english_words = en_file.read.split(";")

english_words.each do |word|
  comment_split = word.split("*")
  comment = comment_split[1]
  puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  puts "comment"
  puts  comment

  puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  puts 'word'
  word_split = word.split("=")
  english = word_split.last.split("\"")
  puts english

  # e = EnglishWord.new(comment: comment, translatable_string: english)
  # if (e.valid?)
    # e.save
  # else
    # puts "English: #{english} #{e.errors.full_messages}"
  # end
end

#create words for other languages
languages = []#LANGUAGES
language_folder_mappings = LANGUAGE_FOLDER_MAPPINGS

languages.each do |language|
  language_folder = language_folder_mappings[language] || language
  language_file_path = "#{file_root}/#{language_folder}.lproj/Localizable.strings"
  language_file = File.open(language_file_path, encoding)

  language_words = language_file.read.split(";")

  language_words.each do |word|
    if (word.length > 0)
      puts word
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

