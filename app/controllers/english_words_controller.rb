class EnglishWordsController < ApplicationController
  def index
    @english = EnglishWord.all
  end

  def localizable
    index
  end
end
