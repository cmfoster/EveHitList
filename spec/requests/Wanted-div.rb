require 'spec_helper'

describe "home page" do

  it "displays the wanted toons wanted modal window", :js => true do
    # click "Character_button"
    @target = WantedToon.create!(:active_bounty => true, :name => "test", :bounty => 2000000, :character_id => 1436418183,
    :corporation => "test", :alliance => "test")
    visit "/"
    post "/gettoons.js", :character_id => @target.character_id
    response.body.should include("1436418183")
  end
end
