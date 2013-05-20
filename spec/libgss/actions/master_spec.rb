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

  describe "#find_all" do
    it "basic call" do
      callback_called = false
      request.find_all("Item")
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        items = outputs.first["result"]
        items.length.should == 12
        items.each do |item|
          item["item_cd"].should_not == nil
          item["name"].should_not == nil
        end
      end
      callback_called.should == true
    end

    it "with conditions" do
      callback_called = false
      request.find_all("Item", {"item_cd$gte" => 20005, "item_cd$lte" => 20008})
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        items = outputs.first["result"]
        items.length.should == 4
        items.each do |item|
          item["item_cd"].should_not == nil
          item["name"].should_not == nil
        end
      end
      callback_called.should == true
    end

    it "with order and conditions" do
      callback_called = false
      request.find_all("Item", {"item_cd$gte" => 20005, "item_cd$lte" => 20008}, [["item_cd", "desc"]])
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        items = outputs.first["result"]
        items.length.should == 4
        items.map{|item| item["item_cd"]}.should == [20008, 20007, 20006, 20005]
      end
      callback_called.should == true
    end
  end

  describe "#paginate" do
    it "with pagination" do
      callback_called = false
      request.paginate("Item", 2, 5, nil, [["item_cd", "desc"]])
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        items = outputs.first["result"]
        items.length.should == 5
        items.map{|item| item["item_cd"]}.should == [20007, 20006, 20005, 20004, 20003]
      end
      callback_called.should == true
    end
  end

  describe "#count" do
    it "no option" do
      callback_called = false
      request.count("Item")
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        outputs.first["result"].should == 12
      end
      callback_called.should == true
    end

    it "with conditions" do
      callback_called = false
      request.count("Item", {"item_cd$gte" => 20005, "item_cd$lte" => 20008})
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        outputs.first["result"].should == 4
      end
      callback_called.should == true
    end
  end

  describe "#find_first" do
    it "basic call" do
      callback_called = false
      request.find_first("Item")
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        item = outputs.first["result"]
        item["item_cd"].should == 20001
      end
      callback_called.should == true
    end

    it "with conditions" do
      callback_called = false
      request.find_first("Item", {"item_cd$gte" => 20005, "item_cd$lte" => 20008})
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        item = outputs.first["result"]
        item["item_cd"].should == 20005
      end
      callback_called.should == true
    end

    it "with order and conditions" do
      callback_called = false
      request.find_first("Item", {"item_cd$gte" => 20005, "item_cd$lte" => 20008}, [["item_cd", "desc"]])
      request.send_request do |outputs|
        callback_called = true
        outputs.length.should == 1
        item = outputs.first["result"]
        item["item_cd"].should == 20008
      end
      callback_called.should == true
    end
  end

end

