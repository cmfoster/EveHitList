FactoryGirl.define do
  factory :wanted_toon do
    name   "Zer0 Kool"
    active_bounty   true
    bounty   1000000000000 
    character_id   10
    corporation  "TEST"
    alliance "TEST"
  end
end