require 'spec_helper'

describe "home page" do
  before :each do 
    target = FactoryGirl.create(:wanted_toon)
  end
  it "displays the wanted toons wanted modal window", :js => true do
    # click "Character_button"
    visit "/"
    post "/gettoons.js", :character_id => target.character_id
    page.should have_selector("p.target", :text => "TEST")
  end
end
