# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do

  let(:network) do
    network = Libgss::Network.new("http://localhost:3000")
    network.player_id = "1000001"
    network.login
    network
  end

  let(:request) do
    network.new_action_request
  end


  describe "ruby_stored_script#execute" do
    before do
      request_fixture_load("01_basic")
      # HP満タンなので、減らす
      req1 = network.new_action_request
      req1.get_by_game_data
      req1.send_request # コールバックなしでもOK

      req1.outputs.length.should == 1
      game_data = req1.outputs.first["result"]
      new_content_attrs = {"hp" => 10} # 5ポイント減らす
      game_data["content"].update(new_content_attrs)
      #
      req2 = network.new_action_request
      req2.update("GameData", game_data)
      req2.send_request
      req2.outputs.first["result"].should == "OK"
    end


    it "valid" do
      callback_called = false
      request.execute("ItemRubyStoredScript", "use_item", {"item_cd" => "20001"})
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        outputs.first["result"].should == "recovery hp 5points"
      end
      callback_called.should == true
    end

    it "invalid args" do
      pending "どう振る舞うべきか検討"
      callback_called = false
      request.execute("ItemRubyStoredScript", "use_item", {}) # 引数の指定なし
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        outputs.first["result"].should == "recovery hp 5points"
      end
      callback_called.should == true
    end
  end

end
