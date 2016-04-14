require './lib/assets/message_handler'


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

      facebook_id = message['sender']['id']
      text = message['message']['text']

      #sender = Sender.find_by_facebook_id facebook_id
      #if sender
      #  message_handler = MessageHandler.new(facebook_id)
      #  json = message_handler.handle_message(text)
      #else
      #  Sender.recreate(facebook_id)
      #  message_handler = MessageHandler.new(facebook_id)
      #  json = message_handler.post_message
      #end

      Sender.recreate(facebook_id)
      message_handler = MessageHandler.new(facebook_id)
      json = message_handler.post_message
    end

    render json: json
  end


end
