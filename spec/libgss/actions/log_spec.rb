# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do

  let(:network) do
    network = Libgss::Network.new("http://localhost:3000")
    network.player_id = "1000001"
    network
  end

  let(:request) do
    network.login
    network.new_action_request
  end


  describe "log#create" do
    it "valid" do
      callback_called = false
      # player_id, created_atはサーバで設定されます。
      request.create("ItemIncomingLog", {"level" => 1, "item_cd" => 10001, "incoming_route_cd" => 1, "amount" => 2})
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        outputs.first["result"].should == "OK"
      end
      callback_called.should == true
    end

    shared_examples_for "log#create invalid" do |error_code, attrs|
      it "with additional field" do
        callback_called = false
        request.create("ItemIncomingLog", attrs)
        request.send_request do |outputs|
          callback_called = true
          outputs.length.should == 1
          error = outputs.first["error"]
          error.should_not be_nil
          error["message"].should =~ /^#{error_code}\:/
          error["input"].should == {
            "id" => 1,
            "name" => "ItemIncomingLog",
            "attrs" => attrs,
            "action"=>"create"
          }
          outputs.first["id"].should == 1
          outputs.first["result"].should == nil
        end
        callback_called.should == true
      end
    end

    it_should_behave_like "log#create invalid", 1004, {"level" => 1, "item_cd" => 10001, "incoming_route_cd" => 1, "amount" => 2, "extra_field" => 100}
    it_should_behave_like "log#create invalid", 1005, {"level" => 1, "item_cd" => 10001, "incoming_route_cd" => 1} # 必須のフィールドamountがないのでエラー
  end

end
