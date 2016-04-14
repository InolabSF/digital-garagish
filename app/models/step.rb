class Step < ActiveRecord::Base
  belongs_to :sender
  validates :sender_id, :start_lat, :start_lng, :end_lat, :end_lng, :distance_text, :duration_text, :html_instructions
end
