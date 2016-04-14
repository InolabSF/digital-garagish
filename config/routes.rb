Rails.application.routes.draw do

  get 'webhook/facebook', :to => 'webhook#get_facebook'
  post 'webhook/facebook', :to => 'webhook#post_facebook'

end
