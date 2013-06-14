# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Libgss::AssetRequest" do
  before(:all) do
    request_fixture_load("01_basic")
  end

  let(:network) do
    network = new_network
    network.public_asset_url_prefix = "http://localhost:3000/a/"
    network.login
    network
  end

  describe "public asset" do
    it "valid" do
      req = network.new_public_asset_request("Default.png")
      req.send_request
      req.response_data.should == IO.binread(File.expand_path("../../public_assets/Default.png", __FILE__))
    end
  end

  describe "protected asset" do
    it "valid" do
      req = network.new_protected_asset_request("Icon.png")
      req.send_request
      req.response_data.should == IO.binread(File.expand_path("../../protected_assets/Icon.png", __FILE__))
    end
  end

end
