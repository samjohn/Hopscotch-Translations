class GengoResponsesController < ApplicationController
  def index
    @gengo_responses = GengoResponse.all
  end

  def create
    g = GengoResponse.new(resp_text: params)
    g.save
  end
end
