require './lib/assets/google_client'
require './lib/assets/facebook_client'


class WebhookController < ApplicationController


  def get_facebook
    verify_token = params['hub.verify_token']
    render :status => 401 and return unless verify_token == ENV['FB_VERIFY_TOKEN']
    challenge = params['hub.challenge']
    render :status => 401 and return unless challenge

    render json: challenge
  end


  def post_facebook
    message = params['entry'][0]['messaging'][0]
    if message.include?('message')

      sender_id = message['sender']['id']
      text = message['message']['text']

      facebook_client = FacebookClient.new
      facebook_client.post_message(sender_id, text)
    end

    render :status => 200
  end


end
