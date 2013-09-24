require 'open-uri'
class ForeignWord < ActiveRecord::Base
  belongs_to :english_word, primary_key: :translatable_string, foreign_key: :translatable_string
  validates_uniqueness_of :translatable_string, :scope => :language
  validates :english_word, presence: true

  def self.create_foreign_word_from_data(line, language)
    split_word = line.split("\"")
    english = split_word[1]
    translation = split_word[3]

    f = self.new(translatable_string: english,
                        language: language,
                        translated_string: translation)
    if (f.valid?)
      f.save
    else
      puts "#{language}, #{english} #{f.errors.full_messages}"
    end
  end

  def self.get_words_for_language(language, file_root_url, encoding)
    language_folder = LANGUAGE_FOLDER_MAPPINGS[language] || language
    language_file_path = "#{file_root_url}/#{language_folder}.lproj/Localizable.strings"
    puts language_file_path
    local_file_path = Rails.root.join("tmp", "localizable.strings")

    open(local_file_path, "wb:#{encoding}") do |file|
      file.print open(language_file_path, "rb:#{encoding}").read
    end

    language_file = open(local_file_path, "rb:#{encoding}")
    language_words = language_file.read

    return language_words.split(";")
  end
end
