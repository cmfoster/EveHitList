EveHitlist::Application.routes.draw do

  root :to => 'home#index'
  
  resource :wanted_toons 
  match "gettoons" => "wanted_toons#gettoons", :via => :post

end