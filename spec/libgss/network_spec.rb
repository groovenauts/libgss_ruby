require 'spec_helper'

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
        res.should == true
      end
    end
  end

  describe "#initialize" do
    context "with_trail_slash" do
      let(:target){ new_network("http://localhost:4000/") }
      it{ target.base_url.should == network.base_url }
      it{ target.ssl_base_url.should == network.ssl_base_url }
    end
    context "hostname only" do
      let(:target){ new_network("localhost") }
      it{ target.base_url.should == "http://localhost:80" }
      it{ target.ssl_base_url.should == "https://localhost:443" }
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
          res = double(:reponse)
          res.stub(:status).and_return(200)
          res.should_receive(:content).and_return("invalid JSON format string")
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

end
