# -*- coding: utf-8 -*-
require 'spec_helper'

require 'uuid'
require 'securerandom'

describe Libgss::Network do

  let(:network) do
    # Libgss::Network.new("http://localhost:4000")
    new_network
  end

  describe "#setup" do
    context "valid" do
      it do
        # network.player_id.should == nil
        network.auth_token.should == nil
        network.signature_key.should == nil
        res = network.setup
        network.player_id.should_not == nil
        network.auth_token.should_not == nil
        network.signature_key.should_not == nil
        network.ignore_oauth_nonce.should == false
        network.oauth_nonce.should == nil
        network.oauth_timestamp.should == nil
        res.should == true
      end
    end
  end

  describe "#initialize" do
    context "with_trail_slash" do
      let(:target){ new_network_with_options(url: "http://localhost:4000/") }
      it{ target.base_url.should == network.base_url }
      it{ target.ssl_base_url.should == network.ssl_base_url }
    end
    context "hostname only" do
      let(:target){ new_network("localhost") }
      it{ target.base_url.should == "http://localhost:#{ENV['DEFAULT_HTTP_PORT' ] ||  80}" }
      it{ target.ssl_base_url.should == "https://localhost:#{ENV['DEFAULT_HTTPS_PORT' ] || 443}" }
    end
  end

  describe "#login" do
    before do
      network.player_id = "1000001"
    end

    context "success" do
      shared_examples_for "Libgss::Network#login success" do |block, after_block = nil|
        before(&block)
        after(&after_block) if after_block

        it do
          network.auth_token.should == nil
          network.signature_key.should == nil
          res = network.login
          network.auth_token.should_not == nil
          network.signature_key.should_not == nil
          res.should == true
        end
      end

      it_should_behave_like "Libgss::Network#login success", Proc.new{ network.player_id = "1000001" }
      # it_should_behave_like "Libgss::Network#login success", Proc.new{ network.player_id = "unregistered" }

      it_should_behave_like "Libgss::Network#login success",
        Proc.new{ network.player_id = nil },
        Proc.new{ network.player_id.should_not == nil }

      it "update player_info with generate_device_id" do
        network.player_info.should == {}
        network.generate_device_id
        network.login!
        keys = [:id, :device_id, :device_type]
        network.player_info.keys =~ keys
        keys.each do |k|
          network.player_info[k].should_not be_nil
        end
      end

      it "update player_info with generate_device_id and extra data" do
        network.player_info.should == {}
        network.generate_device_id
        network.login!(foo: "bar")
        keys = [:id, :device_id, :device_type, :foo]
        network.player_info.keys =~ keys
        keys.each do |k|
          network.player_info[k].should_not be_nil
        end
      end
    end

    context "failure with unregistered (maybe invalid) player_id" do
      before do
        network.player_id = "unregistered"
        network.auth_token.should == nil
        network.signature_key.should == nil
      end

      it "by using login" do
        res = network.login
        network.auth_token.should == nil
        network.signature_key.should == nil
        res.should == false
      end
      it "by using login!" do
        expect{ network.login! }.to raise_error(Libgss::Network::Error)
      end
    end

    context "error" do
      shared_examples_for "Libgss::Network#login failure" do
        it "by using login"do
          network.auth_token.should == nil
          network.signature_key.should == nil
          res = network.login
          network.auth_token.should == nil
          network.signature_key.should == nil
          res.should == false
        end
        it "by using login"do
          network.auth_token.should == nil
          network.signature_key.should == nil
          expect{ network.login! }.to raise_error(Libgss::Network::Error)
        end
      end

      [300, 400, 500].map{|n| (1..10).map{|i| n + i} }.flatten.each do |status_code|
        context "status_code is #{status_code}" do
          before do
            res = double(:reponse)
            res.should_receive(:status).and_return(status_code)
            HTTPClient.any_instance.should_receive(:post).and_return(res)
          end
          it_should_behave_like "Libgss::Network#login failure"
        end
      end

      context "JSON parse Error" do
        before do
          $stderr.stub(:puts).with(an_instance_of(String)) # $stderrにメッセージが出力されます
          res = double(:reponse)
          res.stub(:status).and_return(200)
          res.should_receive(:content).twice.and_return("invalid JSON format string")
          HTTPClient.any_instance.should_receive(:post).and_return(res)
        end

        it_should_behave_like "Libgss::Network#login failure"
      end

    end

  end

  describe "#login(with Cathedral)" do
    before do
      @gdkey = SecureRandom.uuid
      @extras = {udkey: SecureRandom.uuid, gdkey: @gdkey, device_cd: "10"}
      network.player_id = nil
      network.platform = 'cathedral'
      network.client_version = "2013073101"
      network.device_type_cd = 1
    end

    context "success" do
      shared_examples_for "Libgss::Network#login(cathedral) success" do |block, after_block = nil|
        before(&block) if block
        after(&after_block) if after_block

        it do
          network.platform.should eq 'cathedral'
          network.auth_token.should eq nil
          network.signature_key.should eq nil

          res = network.login(@extras)
          res.should eq true
          network.auth_token.should_not eq nil
          network.signature_key.should_not eq nil

          req = network.new_action_request
          req.get_by_player
          req.send_request do |outputs|
            outputs.should have(1).results
            outputs[0].should have_key('result')
            @result = outputs[0]['result']
          end
        end
      end

      it_should_behave_like("Libgss::Network#login(cathedral) success",
        nil, Proc.new{
          network.player_id.should eq @gdkey
          @result['player_id'].should eq @gdkey
        })

      it_should_behave_like("Libgss::Network#login(cathedral) success",
        Proc.new{ @extras = @extras.update({udkey: nil}) },
        Proc.new{
          network.player_id.should eq @gdkey
          @result['player_id'].should eq @gdkey
        })

      it_should_behave_like("Libgss::Network#login(cathedral) success",
        Proc.new{ @extras = @extras.update({device_cd: nil}) },
        Proc.new{
          network.player_id.should eq @gdkey
          @result['player_id'].should eq @gdkey
        })
    end

    context "failure with gdkey is brank" do
      it "by using login" do
        res = network.login({gdkey: nil})
        network.auth_token.should == nil
        network.signature_key.should == nil
        res.should == false
      end
      it "by using login!" do
        expect{ network.login!({gdkey: nil}) }.to raise_error(Libgss::Network::Error)
      end
    end

    context "error" do
      shared_examples_for "Libgss::Network#login failure" do
        it "by using login"do
          network.auth_token.should == nil
          network.signature_key.should == nil
          res = network.login(@extras)
          network.auth_token.should == nil
          network.signature_key.should == nil
          res.should == false
        end
        it "by using login"do
          network.auth_token.should == nil
          network.signature_key.should == nil
          expect{ network.login!(@extras) }.to raise_error(Libgss::Network::Error)
        end
      end

      [300, 400, 500].map{|n| (1..10).map{|i| n + i} }.flatten.each do |status_code|
        context "status_code is #{status_code}" do
          before do
            res = double(:reponse)
            res.should_receive(:status).and_return(status_code)
            HTTPClient.any_instance.should_receive(:post).and_return(res)
          end
          it_should_behave_like "Libgss::Network#login failure"
        end
      end

      context "JSON parse Error" do
        before do
          $stderr.stub(:puts).with(an_instance_of(String)) # $stderrにメッセージが出力されます
          res = double(:reponse)
          res.stub(:status).and_return(200)
          res.should_receive(:content).twice.and_return("invalid JSON format string")
          HTTPClient.any_instance.should_receive(:post).and_return(res)
        end

        it_should_behave_like "Libgss::Network#login failure"
      end

    end

  end

  describe "#new_action_request" do

    let(:req){ network.new_action_request }
    subject{ req }
    its(:status){ should == Libgss::ActionRequest::STATUS_PREPARING }
  end

  describe "#inspect" do
    it "doesn't contain @httpclient" do
      network.inspect.should_not =~ /@httpclient/
    end

    # it "isn't too long" do
    #   network.inspect.length.should < 300
    # end
  end


  describe "load_app_garden" do
    it "without filepath" do
      network.consumer_secret = nil
      network.platform = nil
      Dir.chdir(File.expand_path("../../../fontana_sample", __FILE__)) do
        network.load_app_garden
      end
      network.consumer_secret.should_not be_nil
      network.platform.should be_nil
    end

    it "with filepath" do
      network.consumer_secret = nil
      network.platform = "fontana"
      network.load_app_garden(File.expand_path("../../../fontana_sample/config/app_garden.yml", __FILE__))
      network.consumer_secret.should_not be_nil
      network.platform.should == "fontana"
    end
  end

  describe "generate_device_id" do
    let(:generated){ UUID.new.generate }

    before do
      network.uuid_gen.should_receive(:generate).and_return(generated)
      network.player_info.should == {}
    end

    it "without options" do
      network.generate_device_id
      network.player_info.should == {device_type: 1, device_id: generated}
    end

    it "with device_type" do
      network.generate_device_id(device_type: 2)
      network.player_info.should == {device_type: 2, device_id: generated}
    end
  end

  describe "with oauth options" do

    def spec_with_network_options(opts={}, &block)
      r = new_network_with_options(opts).tap(&:login).new_action_request
      r.server_time
      r.send_request do |outputs|
        outputs.length.should == 1
        result = outputs.first['result']
        yield(result) if block_given?
      end
    end

    context "success" do
      it "with ignore_oauth_nonce" do
        spec_with_network_options({ignore_oauth_nonce: true})
      end
      it "with oauth_nonce" do
        spec_with_network_options({oauth_nonce: UUID.new.generate})
      end
      it "with oauth_timestamp" do
        time = Time.now
        spec_with_network_options({oauth_timestamp: time.to_i})
      end
    end
    context "401 error" do
      it "with empty oauth_nonce" do
        proc{
          spec_with_network_options({oauth_nonce: ''})
        }.should raise_error(::Libgss::ActionRequest::Error)
      end
      it "with old oauth_timestamp" do
        time = Time.local(2013,7,1,12,0,0)
        proc{
          spec_with_network_options({oauth_timestamp: time.to_i})
        }.should raise_error(::Libgss::ActionRequest::Error)
      end
    end
  end
end
