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

      token = ENV['FB_ACCESS_TOKEN']
      endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token=" + token
      request_content = {recipient: {id:sender_id},
                         message: {text: text}
                        }
      content_json = request_content.to_json
      json = RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8'
      }){ |response, request, result, &block|
      }
    end

    render json: json
  end


end
