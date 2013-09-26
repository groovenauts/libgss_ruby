
require 'factory_girl'

FactoryGirl.define do

  factory :async_action01, class: AsyncAction do
    player
    action_id   "1"
    request_url "http://localhost:3000/api/1.0.0/async_actions.json?auth_token=CzyWmCg3vjpxeYuHL8dr"
    request({"id"=>1, "action"=>"server_time"})
    # response({"result"=>1379990870, "id"=>1})
    attempts 0
  end

  factory :async_action02, class: AsyncAction do
    player
    action_id   "2"
    request_url "http://localhost:3000/api/1.0.0/async_actions.json?auth_token=CzyWmCg3vjpxeYuHL8dr"
    request({"id"=>2, "action"=>"server_time"})
    response({"result"=>1379990870, "id"=>"2"})
    attempts 0
  end

  factory :player, class: Player do
    player_id             "1000001"
    nickname              "ichiro"
    pf_player_id          "150001"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-07-15T21:50:00+09:00")
    current_login_at      Time.zone.parse("2012-08-15T18:50:00+09:00")
    last_login_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    login_days            100
    login_count_this_day  3
    continuous_login_days 5
    created_at            Time.zone.parse("2012-08-15T18:50:00+09:00")
    updated_at            Time.zone.parse("2012-08-15T18:50:00+09:00")
  end
end
