# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::AsyncActionRequest do

  before(:all) do
    ClientRelease.delete_all
    FactoryGirl.create(:client_release01)
  end

  let(:network){ @network }

  describe "POST async_action.json" do
    before do
      Player.delete_all
      AsyncAction.delete_all
      create(:player01)
      @network = new_network.login!
    end

    context "success" do
      it do
        r = network.new_async_action_request
        r.server_time
        r.send_request.to_a.should == [{"id" => 1, "status" => "executing" }]
      end

      it "id is string" do
        r = network.new_async_action_request
        r.server_time.with("10001")
        r.send_request.to_a.should == [{"id" => "10001", "status" => "executing" }]
      end

      it "id is integer" do
        r = network.new_async_action_request
        r.server_time.with(10001)
        r.send_request.to_a.should == [{"id" => 10001, "status" => "executing" }]
      end
    end

    context "failed" do
      it "action_id is empty" do
        r = network.new_async_action_request
        r.server_time.with(nil)
        r.send_request.to_a.should == [{"id" => nil, "status" => "failed", "reason"=>{"action_id"=>["can't be blank"]}}]
      end

      it "action_id is duplicated" do
        r = network.new_async_action_request
        r.server_time.with(1)
        r.server_time.with(1)
        r.send_request.to_a.should == [
          {"id" => 1, "status" => "executing"},
          {"id" => 1, "status" => "failed", "reason"=>{"action_id"=>["is already taken"]}},
        ]
      end

      it "request is empty" do
        r = network.new_async_action_request
        a = r.add_action({})
        a.should_receive(:to_hash).and_return({})
        r.send_request.to_a.should == [
          {"id" => nil, "status" => "failed", "reason"=>{
              "action_id"=>["can't be blank"],
              "request"=>["can't be blank"]
            }}]
      end
    end

  end

  describe "async_status(POST: async_results.json)" do

    context "working async_action" do
    it do
      r = network.new_async_action_request
      r.server_time
      r.send_request.to_a.should == [{"id" => 1, "status" => "executing" }]
    end
  end


  describe "async_status" do

    context "working async_action" do

      before do
        Player.delete_all
        AsyncAction.delete_all
        @async_action01 = FactoryGirl.create(:async_action01)
        @player01 = @async_action01.player
        @network = new_network(@player01.player_id).login!
      end

      it do
        r = network.new_async_action_request
        r.async_status(['1']).to_a.should == [{"id" => '1', "status" => "executing" }]
      end
    end

    context "executed async_action" do
      before do
        Player.delete_all
        AsyncAction.delete_all
        @async_action02 = create(:async_action02)
        @player02 = @async_action02.player
        @network = new_network(@player02.player_id).login!
      end

      it do
        r = network.new_async_action_request
        r.async_status(['2']).to_a.should == [{"id" => '2', "result" => 1379990870}]
      end
    end

    context "action_id is not exists" do
      before do
        Player.delete_all
        AsyncAction.delete_all
        @async_action01 = FactoryGirl.create(:async_action01)
        @player01 = @async_action01.player
        @network = new_network(@player01.player_id).login!
      end

      it do
        r = network.new_async_action_request
        r.async_status(['3']).to_a.should == [{"id" => '3', "status" => "not_found", "message"=>"not found for id: \"3\""}]
      end
    end

  end

end
