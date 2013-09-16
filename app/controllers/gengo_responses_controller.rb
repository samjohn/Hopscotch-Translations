class GengoResponsesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
  def index
    @gengo_responses = GengoResponse.all
  end

  def create
    puts params
    g = GengoResponse.new(resp_text: params.to_json)
    g.save
    render text: "success"
  end
end
