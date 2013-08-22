# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do
  before do
    request_fixture_load("01_basic")
  end

  let(:network) do
    network = new_network
    network.login.should == true
    network
  end

  let(:request) do
    network.new_action_request
  end

  describe "#server_time" do
    it "basic call" do
      t1 = Time.now.to_i
      callback_called = false
      callback = Proc.new do |outputs|
        callback_called = true
        t2 = Time.now.to_i
        outputs.length.should == 1
        t = outputs.first["result"]
        t.should >= t1 # 秒単位だと同じ場合がある
        t.should <= t2
      end
      request.server_time
      request.send_request(&callback)
      callback_called.should == true
    end

  end

  describe "#server_date" do
    shared_examples_for "Libgss::ActionRequest#server_date" do |time, date|
      it do
        request.server_date(time)
        request.send_request
        request.outputs.length.should == 1
        request.outputs.first["result"].should == date
      end
    end

    # デフォルトでは業務日付の切り替えは04:00に行われます
    it_should_behave_like "Libgss::ActionRequest#server_date", Time.parse("2017/7/10 03:59:59+09:00"), "2017-07-09"
    it_should_behave_like "Libgss::ActionRequest#server_date", Time.parse("2017/7/10 04:00:00+09:00"), "2017-07-10"
    it_should_behave_like "Libgss::ActionRequest#server_date", Time.parse("2017/7/10 04:00:01+09:00"), "2017-07-10"
  end


  expected_player_1000001 = {
    "player_id"=>"1000001",
    "nickname"=>nil,
    "level"=>1,
    "first_login_at"=> Time.parse("2012/7/15 21:50+09:00").to_i, # 1342356600,
    # "current_login_at"=>1366678900,
    # "last_login_at"=>1366678900,
    "first_paid_at"=>nil,
    "last_paid_at"=>nil,
    "login_days"=>101,
    "login_count_this_day"=>1,
    "continuous_login_days"=>1
  }

  describe "#get" do
    context "Player" do
      it do
        request.get_by_player
        request.send_request do |outputs|
          outputs.length.should == 1
          player = outputs.first["result"]
          # puts player.inspect
          # AppSeedで定義されているデータの確認
          player.select!{|k,v| expected_player_1000001.keys.include?(k) }
          player.should == expected_player_1000001
        end
      end
    end
  end

  describe "bulk action" do
    before do
      request_fixture_load("01_basic")
    end

    context "server_time and get_by_player" do
      it "using array index" do
        request.server_time   # 1
        request.get_by_player # 2
        callback_called = false
        t1 = Time.now.to_i
        request.send_request do |outputs|
          callback_called = true
          outputs.length.should == 2
          # 1
          t2 = Time.now.to_i
          t = outputs[0]["result"]
          t.should >= t1 # 秒単位だと同じ場合がある
          t.should <= t2
          # 2
          player = outputs[1]["result"]
          player.select!{|k,v| expected_player_1000001.keys.include?(k) }
          player.should == expected_player_1000001
        end
        callback_called.should == true
      end

      ACITON_ID_SERVER_TIME = 10000001
      ACITON_ID_GAME_DATA   = 10000002
      ACITON_ID_PLAYER      = 10000003

      # バルクアクションには大量のアクションが含まれることがあり、
      # その中には状況によってアクションが呼ばれないこともあります。
      # そのような場合は、バルクアクションの順番によって結果を取得することが
      # 難しいので、アクションに固有の番号をつけると簡単になります。
      it "using specified ID" do
        a1 = request.server_time
        a1.id = ACITON_ID_SERVER_TIME

        if false # ここはこのテストでは実行されませんが、本番では動くかも。
          a2 = request.get_by_game_data.with(ACITON_ID_GAME_DATA) # withメソッドで短く書くこともできます。
        end

        request.get_by_player.with(ACITON_ID_PLAYER)

        callback_called = false
        t1 = Time.now.to_i
        request.send_request do |outputs|
          callback_called = true
          outputs.length.should == 2
          # a1
          output1 = outputs.get(ACITON_ID_SERVER_TIME)
          t = output1["result"]
          t2 = Time.now.to_i
          t.should >= t1 # 秒単位だと同じ場合がある
          t.should <= t2

          if output2 = outputs.get(ACITON_ID_GAME_DATA)
            fail "why this data is set? #{output2.inspect}"
          end

          # a3
          output3 = outputs.get(ACITON_ID_PLAYER)
          player = output3["result"]
          player.select!{|k,v| expected_player_1000001.keys.include?(k) }
          player.should == expected_player_1000001
        end
        callback_called.should == true
      end


      it "outputs is an Enumerable" do
        request.get_by_player.with(ACITON_ID_PLAYER)
        request.server_time.with(ACITON_ID_SERVER_TIME)
        request.get_by_game_data.with(ACITON_ID_GAME_DATA) # withメソッドで短く書くこともできます。
        request.send_request
        request.outputs.map{|r| r["id"]}.should == [ACITON_ID_PLAYER, ACITON_ID_SERVER_TIME, ACITON_ID_GAME_DATA]
      end

    end
  end

end
