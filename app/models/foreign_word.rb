class ForeignWord < ActiveRecord::Base
  validates_uniqueness_of :translatable_string, :scope => :language
end
