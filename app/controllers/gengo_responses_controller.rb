class GengoResponsesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
  def create
    Rails.logger.info params
    render text: "success"
  end
end
