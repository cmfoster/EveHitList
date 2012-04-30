EveHitlist::Application.routes.draw do
  require "resque/server"
  
  root :to => 'home#index'
  
  resource :wanted_toons 
  match "gettoons" => "wanted_toons#gettoons", :via => :post
  mount Resque::Server.new, :at => "/admin/jobs"

end
