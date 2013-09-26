# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do

  let(:network) do
    network = new_network
    network.player_id = "1000001"
    network.login
    network
  end

  let(:request) do
    network.new_action_request
  end

  expected_game_data_1000001 = {
    "content"=>{
      "hp"=>15,
      "max_hp"=>15,
      "mp"=>5,
      "max_mp"=>5,
      "exp"=>100,
      "money"=>200,
      "items"=>{"20001"=>3, "20005"=>1},
      "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}
    },
    "gender" => 0,
    "greeting_points"=>0,
    "login_bonus"=>[[10001, 1]],
    "invitation_code"=>nil,
    "invite_player"=>nil,
    "read_notifications"=>[]
  }

  [:get_game_data, :get_by_game_data].each do |action|
  describe "##{action}" do
    before do
      request_fixture_load("01_basic")
    end

    it action do
      callback_called = false
      request.send(action)
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        game_data = outputs.first["result"]
        # AppSeedで定義されているデータの確認
        # game_data.select!{|k,v| expected_game_data_1000001.keys.include?(k) }
        game_data.should == expected_game_data_1000001
      end
      callback_called.should == true
    end
    end
  end

  describe "#update" do
    it "basic call" do
      callback_called = false
      request.get_by_game_data
      request.send_request # コールバックなしでもOK
      request.outputs.length.should == 1
      game_data = request.outputs.first["result"]
      new_content_attrs = {"hp" => 10, "mp" => 3, "exp" => 120, "money" => 220}
      game_data["content"].update(new_content_attrs)
      #
      req1 = network.new_action_request
      req1.update("GameData", game_data)
      req1.send_request
      req1.outputs.first["result"].should == "OK"
      #
      req2 = network.new_action_request
      req2.get_by_game_data
      req2.send_request
      content = expected_game_data_1000001["content"].dup
      content.update(new_content_attrs)
      req2.outputs.first["result"]["content"].should == content
    end

  end

end
