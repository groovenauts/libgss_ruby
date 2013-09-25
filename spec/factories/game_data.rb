# -*- coding: utf-8 -*-

# このファイルは生成されたファイルです。
#
# このファイルを変更する際には、再度生成され、上書きされる
# かもしれないことを考慮してください。
#

require 'factory_girl'

FactoryGirl.define do

  factory :game_data01, class: GameData do
    player_id          "1000001"
    content            ({"hp"=>15, "max_hp"=>15, "mp"=>5, "max_mp"=>5, "exp"=>100, "money"=>200, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    login_bonus        [[10001, 1]]
    read_notifications []
    created_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    gender             1
  end

  factory :game_data02, class: GameData do
    player_id          "1000002"
    content            ({"hp"=>30, "max_hp"=>30, "mp"=>10, "max_mp"=>10, "exp"=>200, "money"=>400, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    greeting_points    10
    login_bonus        [[20001, 1]]
    invite_player      "1000003"
    read_notifications []
    created_at         Time.zone.parse("2012-08-12T10:00:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T10:00:00+09:00")
    gender             1
  end

  factory :game_data03, class: GameData do
    player_id          "1000003"
    content            ({"hp"=>45, "max_hp"=>45, "mp"=>15, "max_mp"=>15, "exp"=>300, "money"=>600, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    greeting_points    20
    invitation_code    "abcdABCD42"
    read_notifications []
    created_at         Time.zone.parse("2012-08-10T01:10:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T01:10:00+09:00")
    gender             1
  end

  factory :game_data04, class: GameData do
    player_id          "1000004"
    content            ({"hp"=>10, "max_hp"=>15, "mp"=>5, "max_mp"=>5, "exp"=>100, "money"=>200, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    login_bonus        [[10001, 1]]
    read_notifications []
    created_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    gender             2
  end

  factory :game_data05, class: GameData do
    player_id          "1000005"
    content            ({"hp"=>20, "max_hp"=>30, "mp"=>5, "max_mp"=>10, "exp"=>200, "money"=>400, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    greeting_points    10
    login_bonus        [[20001, 1]]
    invite_player      "1000006"
    read_notifications []
    created_at         Time.zone.parse("2012-08-12T10:00:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T10:00:00+09:00")
    gender             2
  end

  factory :game_data06, class: GameData do
    player_id          "1000006"
    content            ({"hp"=>40, "max_hp"=>45, "mp"=>15, "max_mp"=>15, "exp"=>300, "money"=>600, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    greeting_points    20
    invitation_code    "abcdABCD42"
    read_notifications []
    created_at         Time.zone.parse("2012-08-10T01:10:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T01:10:00+09:00")
    gender             1
  end

  factory :game_data07, class: GameData do
    player_id          "1000007"
    content            ({"hp"=>1, "max_hp"=>15, "mp"=>5, "max_mp"=>5, "exp"=>100, "money"=>200, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    login_bonus        [[10001, 1]]
    read_notifications []
    created_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    gender             1
  end

  factory :game_data08, class: GameData do
    player_id          "1000008"
    content            ({"hp"=>3, "max_hp"=>30, "mp"=>1, "max_mp"=>10, "exp"=>200, "money"=>400, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    greeting_points    10
    login_bonus        [[20001, 1]]
    invite_player      "1000009"
    read_notifications []
    created_at         Time.zone.parse("2012-08-12T10:00:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T10:00:00+09:00")
    gender             1
  end

  factory :game_data09, class: GameData do
    player_id          "1000009"
    content            ({"hp"=>1, "max_hp"=>45, "mp"=>1, "max_mp"=>15, "exp"=>300, "money"=>600, "items"=>{"20001"=>3, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}})
    greeting_points    20
    invitation_code    "abcdABCD42"
    read_notifications []
    created_at         Time.zone.parse("2012-08-10T01:10:00+09:00")
    updated_at         Time.zone.parse("2012-08-15T01:10:00+09:00")
    gender             2
  end

end
