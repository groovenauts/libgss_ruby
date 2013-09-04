# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::AsyncActionRequest do
  before do
    request_fixture_load("01_basic")
  end

  let(:network) do
    network = new_network
    network.login.should == true
    network
  end

  let(:request) do
    network.new_async_action_request
  end

  describe "#get" do
    context "Player" do
      it do
        request.get_by_player
        request.send_request do |outputs|
          outputs.length.should == 1
          outputs[0]['status'].should eq('executing')
        end
      end
    end

  end

end
