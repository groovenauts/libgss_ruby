# -*- coding: utf-8 -*-

# このファイルは生成されたファイルです。
#
# このファイルを変更する際には、再度生成され、上書きされる
# かもしれないことを考慮してください。
#

require 'factory_girl'

FactoryGirl.define do

  factory :player01, class: Player do
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

  factory :player02, class: Player do
    player_id             "1000002"
    nickname              "jiro"
    level                 2
    pf_player_id          "150002"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-07-21T10:00:00+09:00")
    current_login_at      Time.zone.parse("2012-08-15T10:00:00+09:00")
    last_login_at         Time.zone.parse("2012-08-15T10:00:00+09:00")
    first_paid_at         Time.zone.parse("2012-08-01T12:00:00+09:00")
    last_paid_at          Time.zone.parse("2012-08-15T12:00:00+09:00")
    login_days            20
    login_count_this_day  1
    created_at            Time.zone.parse("2012-08-15T12:00:00+09:00")
    updated_at            Time.zone.parse("2012-08-15T12:00:00+09:00")
  end

  factory :player03, class: Player do
    player_id             "1000003"
    nickname              "subrow"
    level                 3
    pf_player_id          "150003"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-07-26T22:10:00+09:00")
    current_login_at      Time.zone.parse("2012-08-15T01:10:00+09:00")
    last_login_at         Time.zone.parse("2012-08-15T01:10:00+09:00")
    first_paid_at         Time.zone.parse("2012-08-10T20:00:00+09:00")
    last_paid_at          Time.zone.parse("2012-08-10T20:00:00+09:00")
    login_days            30
    login_count_this_day  1
    continuous_login_days 3
    created_at            Time.zone.parse("2012-08-15T01:10:00+09:00")
    updated_at            Time.zone.parse("2012-08-15T01:10:00+09:00")
  end

  factory :player04, class: Player do
    player_id             "1000004"
    nickname              "shirow"
    level                 4
    pf_player_id          "150004"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-08-01T10:20:00+09:00")
    current_login_at      Time.zone.parse("2012-08-14T16:20:00+09:00")
    last_login_at         Time.zone.parse("2012-08-14T16:20:00+09:00")
    login_days            5
    created_at            Time.zone.parse("2012-08-14T16:20:00+09:00")
    updated_at            Time.zone.parse("2012-08-14T16:20:00+09:00")
  end

  factory :player05, class: Player do
    player_id             "1000005"
    nickname              "gorow"
    pf_player_id          "150005"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-07-15T21:50:00+09:00")
    current_login_at      Time.zone.parse("2012-08-15T18:50:00+09:00")
    last_login_at         Time.zone.parse("2012-08-15T18:50:00+09:00")
    login_days            10
    login_count_this_day  3
    continuous_login_days 5
    created_at            Time.zone.parse("2012-08-15T18:50:00+09:00")
    updated_at            Time.zone.parse("2012-08-15T18:50:00+09:00")
  end

  factory :player06, class: Player do
    player_id             "1000006"
    nickname              "rockrow"
    level                 2
    pf_player_id          "150006"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-07-21T10:00:00+09:00")
    current_login_at      Time.zone.parse("2012-08-15T10:00:00+09:00")
    last_login_at         Time.zone.parse("2012-08-15T10:00:00+09:00")
    first_paid_at         Time.zone.parse("2012-08-01T12:00:00+09:00")
    last_paid_at          Time.zone.parse("2012-08-15T12:00:00+09:00")
    login_days            2
    login_count_this_day  1
    created_at            Time.zone.parse("2012-08-15T12:00:00+09:00")
    updated_at            Time.zone.parse("2012-08-15T12:00:00+09:00")
  end

  factory :player07, class: Player do
    player_id             "1000007"
    nickname              "nanarow"
    level                 3
    pf_player_id          "150007"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-07-26T22:10:00+09:00")
    current_login_at      Time.zone.parse("2012-08-15T01:10:00+09:00")
    last_login_at         Time.zone.parse("2012-08-15T01:10:00+09:00")
    first_paid_at         Time.zone.parse("2012-08-10T20:00:00+09:00")
    last_paid_at          Time.zone.parse("2012-08-10T20:00:00+09:00")
    login_days            3
    login_count_this_day  1
    continuous_login_days 3
    created_at            Time.zone.parse("2012-08-15T01:10:00+09:00")
    updated_at            Time.zone.parse("2012-08-15T01:10:00+09:00")
  end

  factory :player08, class: Player do
    player_id             "1000008"
    nickname              "hachi"
    level                 4
    pf_player_id          "150008"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-08-01T10:20:00+09:00")
    current_login_at      Time.zone.parse("2012-08-14T16:20:00+09:00")
    last_login_at         Time.zone.parse("2012-08-14T16:20:00+09:00")
    login_days            1
    created_at            Time.zone.parse("2012-08-14T16:20:00+09:00")
    updated_at            Time.zone.parse("2012-08-14T16:20:00+09:00")
  end

  factory :player09, class: Player do
    player_id             "1000009"
    nickname              "kurow"
    level                 5
    pf_player_id          "150009"
    pf_player_info        ({})
    first_login_at        Time.zone.parse("2012-08-01T10:20:00+09:00")
    current_login_at      Time.zone.parse("2012-08-14T16:20:00+09:00")
    last_login_at         Time.zone.parse("2012-08-14T16:20:00+09:00")
    login_days            1
    created_at            Time.zone.parse("2012-08-14T16:20:00+09:00")
    updated_at            Time.zone.parse("2012-08-14T16:20:00+09:00")
  end

end
