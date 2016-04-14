require './lib/assets/google_client'
require './lib/assets/facebook_client'


class WebhookController < ApplicationController


  skip_before_filter :verify_authenticity_token


  def get_facebook
    verify_token = params['hub.verify_token']
    render 'no verify_token' and return unless verify_token == ENV['FB_VERIFY_TOKEN']
    challenge = params['hub.challenge']
    render 'no challenge' and return unless challenge

    render challenge
  end


  def post_facebook
    json = {}

    message = params['entry'][0]['messaging'][0]
    if message.include?('message')

      sender_id = message['sender']['id']
      text = message['message']['text']

      #facebook_client = FacebookClient.new
      #json = facebook_client.post_message(sender_id, text)
    end

    render json: json
  end


end
