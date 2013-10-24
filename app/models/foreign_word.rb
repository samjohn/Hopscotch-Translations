require 'open-uri'
class ForeignWord < ActiveRecord::Base
  belongs_to :english_word, primary_key: :translatable_string, foreign_key: :translatable_string
  validates_uniqueness_of :translatable_string, :scope => :language
  validates :english_word, presence: true
  has_one :gengo_job
  delegate :comment, to: :english_word
  has_many :submissions, -> { order("created_at DESC") }

  def self.untranslated
    ForeignWord.find_by_sql("select * from foreign_words where id not in (select foreign_word_id from submissions)")
  end

  def self.localizable_strings_for(language)
    words = self.where("language = ?", language)
    string = ""
    words.each do |word|
      string = "#{string}#{word.localizable_string}\n"
    end
    string
  end

  def self.create_foreign_word_from_data(line, language)
    split_word = line.split("\"")
    english = split_word[1]
    translation = split_word[3]

    f = self.new(translatable_string: english, language: language)
    f.submissions.build(translated_string: translation)
    if (f.valid?)
      f.save
      f
    else
      puts "Invalid: #{language}, #{english} #{f.errors.full_messages}"
    end
  end

  def self.get_words_for_language(language, file_root_url, encoding)
    language_folder = LANGUAGE_FOLDER_MAPPINGS[language] || language
    language_file_path = "#{file_root_url}/#{language_folder}.lproj/Localizable.strings"
    puts language_file_path
    `mkdir tmp`
    local_file_path = Rails.root.join("tmp", "localizable.strings")

    open(local_file_path, "wb:#{encoding}") do |file|
      file.print open(language_file_path, "rb:#{encoding}").read
    end

    language_file = open(local_file_path, "rb:#{encoding}")
    language_words = language_file.read

    return language_words.split(";")
  end

  def self.write_file_for_language(language)
    encoding = ENCODING
    local_file_path = Rails.root.join("tmp/#{language}", "Localizable.strings")
    `mkdir -p tmp/#{language}`

    open(local_file_path, "wb:#{encoding}") do |file|
      file.print self.localizable_strings_for(language)
    end
  end

  def translated_string
    submissions.first.try(:translated_string)
  end
  
  def translated_string=(_translated_string)
    submissions.build(:translated_string => _translated_string)
  end

  def localizable_string
    if translated_string
      "\"#{translatable_string}\" = \"#{translated_string}\";"
    else
      ""
    end
  end

  def gengo_hash
    {
      type: "text",
      slug: language,
      comment: comment,
      body_src: translatable_string,
      lc_src: "en",
      lc_tgt: language,
      tier: "standard",
      auto_approve: 1
    }
  end

  def needs_translation_job?
    !doesnt_need_translation_job?
  end

  private
  def doesnt_need_translation_job?
    gengo_job || translatable_string.length < 2
  end

end
