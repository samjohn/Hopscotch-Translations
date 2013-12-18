class EnglishWord < ActiveRecord::Base
  validates_uniqueness_of :translatable_string, presence: true
  has_many :foreign_words, primary_key: :translatable_string, foreign_key: :translatable_string

  def self.delete_all_app_strings
    self.where("non_app_string = ? OR non_app_string IS NULL", false).delete_all
  end

  def self.create_foreign_words
    languages = LANGUAGES
    self.all.each do |english_word|
      languages.each do |language|
        if (ForeignWord.where("language = ? AND translatable_string = ?",
                              language,
                              english_word.translatable_string).count == 0)
          f = ForeignWord.new(language: language,
                              translatable_string: english_word.translatable_string)
          if (f.valid?)
            f.save
          else
            put f.errors.full_messages
          end
        end

      end
    end
  end

  def translated_string
    translatable_string
  end

  def self.words_from_file_url(file_root_url, encoding)
    en_file_url = "#{file_root_url}/Localizable.strings"
    en_file = open(en_file_url, "rb:#{encoding}")

    words = en_file.read.split(";")

    words.map{|w| w.gsub("\n", "") }
  end

  def self.create_word_from_line(line)
    comment_split = line.split("*")
    comment = comment_split[1]

    word_split = line.split("=")
    english = word_split.last.split("\"").last

    if !english.match(/\n/)
      e = self.new(comment: comment, translatable_string: english)
      if (e.valid?)
        e.save
      else
        puts "English: #{english} #{e.errors.full_messages}"
      end
    end
  end

  def localizable_string
    string = "\"#{translatable_string}\" = \"#{translatable_string}\";"
  end

end
