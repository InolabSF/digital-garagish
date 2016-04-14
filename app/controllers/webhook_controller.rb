class WebhookController < ApplicationController


  def get_facebook
    verify_token = params['hub.verify_token']
    render :status => 401 and return unless verify_token == ENV['FB_VERIFY_TOKEN']

    render verify_token
  end


  def post_facebook
    entries = params[:entry]
    render :status => 401 and return unless entries || entries.count

    render :status => 200
  end


end
