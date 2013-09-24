class EnglishWord < ActiveRecord::Base
  validates_uniqueness_of :translatable_string, presence: true
  has_many :foreign_words, primary_key: :translatable_string, foreign_key: :translatable_string

  def translated_string
    translatable_string
  end
end
