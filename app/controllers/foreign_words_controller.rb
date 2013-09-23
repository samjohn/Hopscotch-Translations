class ForeignWordsController < ApplicationController
  def index
    @languages = ForeignWord.uniq.pluck(:language)
  end
  def language
    lang = params[:language]

    @words = ForeignWord.where("language=?", lang)
  end
end
