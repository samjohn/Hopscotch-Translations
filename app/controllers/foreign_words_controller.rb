class ForeignWordsController < ApplicationController
  respond_to :html, :json

  def index
    @languages = ForeignWord.uniq.pluck(:language)
    @language_mappings = {
      cs: "Czech",
      pt: "Portuguese",
      da: "Danish",
      el: "Greek",
      ko: "Korean",
      fi: "Finnish",
      sv: "Swedish",
      :"zh-tw" => "Chinese Traditional",
      de: "German",
      ru: "Russian",
      zh: "Chinese Simplified",
      fr: "French",
      ja: "Japanese",
      he: "Hebrew",
      es: "Spanish",
      nl: "Dutch" }
  end

  def language
    lang = params[:language]

    @words = ForeignWord.where("language=?", lang)

    @words.sort! do |word1, word2|
      if (word1.translated_string.blank? )
        -1
      else
        1
      end
    end
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
