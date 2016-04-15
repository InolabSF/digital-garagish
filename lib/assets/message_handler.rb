require './lib/assets/google_client'
require './lib/assets/facebook_client'


class MessageHandler

  # initialize
  def initialize(facebook_id)
    @server_key = ENV['GOOGLE_API_KEY']
    @sender = Sender.find_by_facebook_id facebook_id
  end

  # handle_error
  def handle_error
    'Sorry. I am not sure what you meant.'
  end


  # post_message
  def post_message
    return nil unless @sender

    facebook_client = FacebookClient.new

    case @sender.navigation_status
    when 0
      json = facebook_client.post_message(@sender.facebook_id, "{ 'text' : 'Where is your current location?' }")
      @sender.navigation_status = 1
      @sender.save if @sender.valid?
      json
    when 1
      start_lat = 37.7844688
      start_lng = -122.4079864
      set_directions(start_lat, start_lng)
      if @sender.steps.count > 0
        @sender.current_step_id = @sender.steps.first.id
        @sender.save if @sender.valid?
      end

      title = 'Are you here?'
      subtitle = ''
      current_step = Step.find_by_id(@sender.current_step_id)
      subtitle = "(#{current_step.start_lat}, #{current_step.start_lng})" if current_step
      img_uri = 'https://dl.dropboxusercontent.com/u/30701586/images/digital-garagish/streetview.jpeg'
      message = "{ 'attachment':{ 'type':'template', 'payload':{ 'template_type':'generic', 'elements':[ { 'title':'#{title}', 'image_url':'#{img_uri}', 'subtitle':'#{subtitle}', 'buttons':[ { 'type':'postback', 'title':'Yes', 'payload':'Yes' }, { 'type':'postback', 'title':'No', 'payload':'No' }, { 'type':'postback', 'title':'Stop navigation', 'payload':'Stop navigation' } ] } ] } } }"

      facebook_client.post_message(@sender.facebook_id, message)
    when 2
      title = 'Let me know when you get there.'
      subtitle = ''
      current_step = Step.find_by_id(@sender.current_step_id)
      subtitle = "(#{current_step.end_lat}, #{current_step.end_lng})" if current_step
      img_uri = 'https://dl.dropboxusercontent.com/u/30701586/images/digital-garagish/streetview.jpeg'
      message = "{ 'attachment':{ 'type':'template', 'payload':{ 'template_type':'generic', 'elements':[ { 'title':'#{title}', 'image_url':'#{img_uri}', 'subtitle':'#{subtitle}', 'buttons':[ { 'type':'postback', 'title':'I got there', 'payload':'I got there' }, { 'type':'postback', 'title':'Stop navigation', 'payload':'Stop navigation' } ] } ] } } }"

      facebook_client.post_message(@sender.facebook_id, message)
    when 3
      facebook_client.post_message(@sender.facebook_id, "{ 'text' : 'Congratulations! You got the destination.' }")
    else
      nil
    end
  end


  # handle_postback
  def handle_postback(message)
    case @sender.navigation_status
    when 0
      nil
    when 1
      if message == 'Yes'
        @sender.navigation_status += 1
        @sender.save if @sender.valid?
        post_message
      elsif message == 'No'
        @sender = Sender.recreate(@sender.facebook_id)
        post_message
      elsif message == 'Stop navigation'
        @sender = Sender.recreate(@sender.facebook_id)
        post_message
      end
    when 2
      if message == 'I got there'
        post_message
      elsif message == 'Stop navigation'
        @sender = Sender.recreate(@sender.facebook_id)
        post_message
      end
    when 3
      nil
    else
      nil
    end
  end


  # set_directions
  def set_directions(start_lat, start_lng)
    # no sender
    return [] unless @sender

    # direction (steps for DG)
    dg_lat = 37.7868614
    dg_lng = -122.4036958
    google_client = GoogleClient.new(@server_key)
    json = google_client.get_directions(start_lat, start_lng, dg_lat, dg_lng)
    json_steps = google_client.parse_get_directions_steps(json)
    json_steps.each do |json_step|
      step = Step.new
      step.sender_id = @sender.id
      step.start_lat = json_step['start_location']['lat'].to_f
      step.start_lng = json_step['start_location']['lng'].to_f
      step.end_lat = json_step['end_location']['lat'].to_f
      step.end_lng = json_step['end_location']['lng'].to_f
      step.distance_text = json_step['distance']['text']
      step.duration_text = json_step['duration']['text']
      step.html_instructions = json_step['html_instructions']
      step.travel_mode = json_step['travel_mode']
      if step.valid?
        step.save
        @sender.steps << step
      end
    end

    @sender.save if @sender.valid?
    @sender.steps
  end

end
