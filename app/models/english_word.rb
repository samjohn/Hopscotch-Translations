class EnglishWord < ActiveRecord::Base
  validates_uniqueness_of :translatable_string
end
