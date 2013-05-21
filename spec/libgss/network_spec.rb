require 'spec_helper'

describe Libgss::Network do

  let(:network) do
    network = Libgss::Network.new("http://localhost:3000")
    network.player_id = "1000001"
    network
  end

  describe "#login" do
    context "success" do
      shared_examples_for "Libgss::Network#login success" do |block|
        before(&block)

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
      it_should_behave_like "Libgss::Network#login success", Proc.new{ network.player_id = "unregistered" }
    end

    context "failure" do
      shared_examples_for "Libgss::Network#login failure" do
        it do
          network.auth_token.should == nil
          network.signature_key.should == nil
          res = network.login
          network.auth_token.should == nil
          network.signature_key.should == nil
          res.should == false
        end
      end

      [300, 400, 500].map{|n| (1..10).map{|i| n + i} }.flatten.each do |status_code|
        context "status_code is #{status_code}" do
          before do
            res = mock(:reponse)
            res.should_receive(:status).and_return(status_code)
            HTTPClient.any_instance.should_receive(:post).and_return(res)
          end
          it_should_behave_like "Libgss::Network#login failure"
        end
      end

      context "JSON parse Error" do
        before do
          res = mock(:reponse)
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

    it "isn't too long" do
      network.inspect.length.should < 200
    end
  end

end
