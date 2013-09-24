# -*- coding: utf-8 -*-
require 'spec_helper'
require 'active_support/core_ext/numeric/time'

describe "response_signature" do
  before do
    request_fixture_load("01_basic")
  end

  shared_examples_for "action_request with response_signature" do
    context "valid" do
      it do
        req = @network.new_action_request
        req.server_time
        req.send_request
      end
    end

    context "invalid response body" do
      before do
        HTTP::Message.any_instance.stub(:content){ {"outputs" => [{"result" => Time.now.to_i - 30.days, "id" => 1}]}.to_json }
      end

      it do
        req = @network.new_action_request
        req.server_time
        expect{ req.send_request }.to raise_error(Libgss::ActionRequest::SignatureError)
      end
    end
  end

  describe "action_request" do
    context "default" do
      before{ @network = new_network.login! }
      it_should_behave_like "action_request with response_signature"
    end

    context "1.0.0" do
      before{ @network = new_network_with_options(api_version: "1.0.0").login! }
      it_should_behave_like "action_request with response_signature"
    end

    context "1.1.0" do
      before{ @network = new_network_with_options(api_version: "1.1.0").login! }
      it_should_behave_like "action_request with response_signature"
    end
  end


  shared_examples_for "async_action_request with response_signature" do
    context "valid" do
      it do
        req = @network.new_async_action_request
        req.server_time
        req.send_request
      end
    end

    context "invalid response body" do
      before do
        HTTP::Message.any_instance.stub(:content){ {"outputs" => [{"result" => Time.now.to_i - 30.days, "id" => 1}]}.to_json }
      end

      it do
        req = @network.new_async_action_request
        req.server_time
        expect{ req.send_request }.to raise_error(Libgss::ActionRequest::SignatureError)
      end
    end
  end

  describe "async_action_request" do
    context "default" do
      before{ @network = new_network.login! }
      it_should_behave_like "async_action_request with response_signature"
    end

    context "1.0.0" do
      before{ @network = new_network_with_options(api_version: "1.0.0").login! }
      it_should_behave_like "async_action_request with response_signature"
    end

    context "1.1.0" do
      before{ @network = new_network_with_options(api_version: "1.1.0").login! }
      it_should_behave_like "async_action_request with response_signature"
    end
  end


end
