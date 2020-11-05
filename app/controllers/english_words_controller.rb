class EnglishWordsController < ApplicationController
  def index
    @english = EnglishWord.all
  end

  def localizable
    index
  end

  def create
    attrs = ActionController::Parameters.new(params[:english_word])

    attrs.permit!

    e = EnglishWord.new(attrs)
    @english = EnglishWord.all
    if (e.save)
      render :index
    else
      flash[:error] = e.errors.full_messages
      render :index
    end
  end
end
