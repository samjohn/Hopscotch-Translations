class ForeignWordsController < ApplicationController
  respond_to :html, :json

  def index
    @languages = ForeignWord.uniq.pluck(:language)
  end

  def language
    lang = params[:language]

    @words = ForeignWord.where("language=?", lang)
  end

  def update
    f = ForeignWord.find(params[:id])
    
    attrs =  ActionController::Parameters.new(params[:foreign_word])
    attrs.permit!
    
    if f.update_attributes(attrs)
      render text: "success"
    else
      render text: 'fail'
    end

  end
end
