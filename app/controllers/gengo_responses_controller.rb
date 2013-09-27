class GengoResponsesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
  def create
    render text: "success"
  end
end
