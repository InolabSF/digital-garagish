class Sender < ActiveRecord::Base
  has_many :steps, dependent: :destroy
  validates :facebook_id, :navigation_status
end
