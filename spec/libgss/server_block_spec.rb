# -*- coding: utf-8 -*-
require 'spec_helper'

describe "サーバ閉塞中" do
  before do
    mock_res = mock(:res, {status: 503, content: "api maintenance"})
    HTTPClient.any_instance.stub(:post).and_return(mock_res)
  end

  context "login" do
    let(:network){ new_network }
    it :login do
      network.login_and_status.should be_a Libgss::ErrorResponse
    end
    it :login! do
      expect{ network.login!}.to raise_error(Libgss::ServerBlockError)
    end
  end

  context "action request" do
    let(:network){ new_network }
    it do
      r = network.new_action_request
      r.server_time
      expect{ r.send_request }.to raise_error(Libgss::ServerBlockError)
    end
  end

end
