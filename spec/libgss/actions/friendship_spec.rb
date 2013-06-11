# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Libgss::ActionRequest friendship" do

  let(:network) do
    network = new_network
    network.login
    network
  end

  let(:request) do
    network.new_action_request
  end

  before do
    request_fixture_load("01_basic")
  end

  describe "#all" do
    it "can't return other player's friendships" do
      request.find_all("Friendship", nil, [["requester_id", "asc"], ["accepter_id", "asc"]])
      request.send_request
      request.outputs.length.should == 1
      result = request.outputs.first["result"]
      result.length.should == 8
      result[0..6].each{|friendship| friendship["requester_id"].should == "fontana:1000001"}
      result[7..7].each{|friendship| friendship["accepter_id" ].should == "fontana:1000001"}
    end
  end

  describe "state" do
    shared_examples_for "friendship state transition" do |target, action, res, *args|
      it "#{action} #{target} => #{res.inspect}, #{args.inspect}" do
        # request.apply("Friendship", target)
        request.send(action, "Friendship", target)

        # request.execute("RubyStoredScript", "get_applyings")
        request.find_all("Friendship", nil, [["requester_id", "asc"], ["accepter_id", "asc"]])
        request.send_request
        request.outputs.length.should == 2

        case res
        when "OK" then
          status_cd, new_data = *args
          request.outputs.first["error"].should == nil
          request.outputs.first["result"].should == "OK"
          # applyings = request.outputs.last["result"]
          friendships = request.outputs.last["result"]
          friendships.length.should == 8 + (new_data ? 1 : 0)
          friendships.detect{|f|
            f["requester_id"] == "fontana:1000001" &&
              f["accepter_id"] == target &&
              f["status_cd"] == status_cd
          }.should_not be_nil

        when "NG" then
          error_cd = args.first
          request.outputs.first["result"].should == nil
          request.outputs.first["error"]["message"].should =~ /\A#{error_cd}:/ # エラー
          friendships = request.outputs.last["result"]
          friendships.length.should == 8
          friendships.detect{|f|
            f["requester_id"] == "fontana:1000001" &&
            f["accepter_id"] == target
          }.should be_nil

        when "IG" then
          status_cd, new_data = *args
          request.outputs.first["result"].should == "OK"
          request.outputs.first["error"].should == nil
          friendships = request.outputs.last["result"]
          friendships.length.should == 8
          if new_data
            friendships.detect{|f|
              f["requester_id"] == "fontana:1000001" &&
              f["accepter_id"] == target
            }.should be_nil
          else
            friendships.detect{|f|
              f["requester_id"] == "fontana:1000001" &&
              f["accepter_id"] == target &&
              f["status_cd"] == status_cd
            }.should_not be_nil
          end
        end

      end
    end

    # status_cd の定数
    FriendshipNone       = 0
    FriendshipApplied_r  = 1
    FriendshipApproved   = 2
    FriendshipDeleted    = 3
    FriendshipApplied_l  = 4
    FriendshipBlocked_r  = 5
    FriendshipBlocked_l  = 6
    FriendshipBlocked_lr = 7

    # フレンドシップがない初期状態
    context "without friendship" do
      it_should_behave_like "friendship state transition", "fontana:1000009", :apply   , "OK", FriendshipApplied_r, :new
      it_should_behave_like "friendship state transition", "fontana:1000009", :approve , "NG", 1003
      it_should_behave_like "friendship state transition", "fontana:1000009", :breakoff, "IG", nil, :new
      it_should_behave_like "friendship state transition", "fontana:1000009", :block   , "OK", FriendshipBlocked_r, :new
      it_should_behave_like "friendship state transition", "fontana:1000009", :unblock , "IG", nil, :new
    end

    context "approve" do
      it_should_behave_like "friendship state transition", "fontana:1000005", :approve , "OK", FriendshipApproved
    end

    context "breakoff" do
      it_should_behave_like "friendship state transition", "fontana:1000002", :breakoff , "OK", FriendshipDeleted
      it_should_behave_like "friendship state transition", "fontana:1000003", :breakoff , "OK", FriendshipDeleted
      it_should_behave_like "friendship state transition", "fontana:1000004", :breakoff , "IG", FriendshipDeleted
      it_should_behave_like "friendship state transition", "fontana:1000005", :breakoff , "OK", FriendshipDeleted
    end

    context "block" do
      it_should_behave_like "friendship state transition", "fontana:1000002", :block , "OK", FriendshipBlocked_r
      it_should_behave_like "friendship state transition", "fontana:1000003", :block , "OK", FriendshipBlocked_r
      it_should_behave_like "friendship state transition", "fontana:1000004", :block , "OK", FriendshipBlocked_r
      it_should_behave_like "friendship state transition", "fontana:1000005", :block , "OK", FriendshipBlocked_r
      it_should_behave_like "friendship state transition", "fontana:1000006", :block , "OK", FriendshipBlocked_r
      it_should_behave_like "friendship state transition", "fontana:1000007", :block , "OK", FriendshipBlocked_lr
      it_should_behave_like "friendship state transition", "fontana:1000008", :block , "OK", FriendshipBlocked_lr
    end

    context "unblock" do
      it_should_behave_like "friendship state transition", "fontana:1000006", :unblock , "OK", FriendshipDeleted
      it_should_behave_like "friendship state transition", "fontana:1000007", :unblock , "OK", FriendshipBlocked_l
      it_should_behave_like "friendship state transition", "fontana:1000008", :unblock , "OK", FriendshipBlocked_l
    end
  end

end
