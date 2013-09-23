class ForeignWord < ActiveRecord::Base
  belongs_to :english_word, primary_key: :translatable_string, foreign_key: :translatable_string
  validates_uniqueness_of :translatable_string, :scope => :language
  validates :english_word, presence: true

  delegate :comment, to: :english_word
end
