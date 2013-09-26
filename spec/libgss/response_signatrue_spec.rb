# -*- coding: utf-8 -*-
require 'spec_helper'
require 'active_support/core_ext/numeric/time'

describe "response_signature" do
  before do
    request_fixture_load("01_basic")
  end
  shared_examples_for "action_request with response_signature" do |api_version|
    before do
      # 通信経路上で実際の時刻より過去の時刻を返すようにレスポンスを改ざんしていることを
      # 想定して、レスポンスオブジェクトのcontentだけ内容を書き換えます。
      @cheat = Proc.new do |res|
        @cheated = res.content.dup
        @cheated.sub!(/"result":(\d+)/){ "\"result\":%d" % ($1.to_i - 30.days) }
        @cheated.sub!(/\\"result\\":(\d+)/){ "\\\"result\\\":%d" % ($1.to_i - 30.days) }
        res.stub(:content).and_return(@cheated)
      end
    end

    context "valid" do
      it do
        req = @network.new_action_request
        req.server_time
        req.send_request
      end
    end

    context "invalid response body" do
      it "raise SignatureError" do
        req = @network.new_action_request
        req.server_time
        req.response_hook = @cheat
        expect{ req.send_request }.to raise_error(Libgss::ActionRequest::SignatureError)
      end

      it "with skip_verifying_signature" do
        @network.skip_verifying_signature = true
        req = @network.new_action_request
        req.server_time
        req.response_hook = @cheat
        expect{ req.send_request }.to_not raise_error(Libgss::ActionRequest::SignatureError)
        # 検証をスキップしているので、通信経路上で改ざんされたデータを取得できてしまう
        req.outputs.to_a.should be_a(Array)
        req.outputs.first.should be_a(Hash)
        req.outputs.first["id"].should == 1
        req.outputs.first["result"].should be_a(Integer)
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
        # 通信経路上で実際の時刻より過去の時刻を返すようにレスポンスを改ざんしていることを
        # 想定して、レスポンスオブジェクトのcontentだけ内容を書き換えます。
        @cheat = Proc.new do |res|
          @cheated = res.content.dup
          @cheated.sub!(/"status":"executing"/){ "\"result\":%d" % (Time.now.to_i - 30.days) }
          @cheated.sub!(/\\"status\\":\\"executing\\"/){ "\\\"result\\\":%d" % (Time.now.to_i - 30.days) }
          res.stub(:content).and_return(@cheated)
        end
      end

      it "raise SignatureError" do
        req = @network.new_async_action_request
        req.server_time
        req.response_hook = @cheat
        expect{ req.send_request }.to raise_error(Libgss::ActionRequest::SignatureError)
      end

      it "with skip_verifying_signature" do
        @network.skip_verifying_signature = true
        req = @network.new_async_action_request
        req.server_time
        req.response_hook = @cheat
        expect{ req.send_request }.to_not raise_error(Libgss::ActionRequest::SignatureError)
        # 検証をスキップしているので、通信経路上で改ざんされたデータを取得できてしまう
        # ここでは「実行中」であるはずの結果が、改ざんされたものになってしまう
        req.outputs.to_a.should be_a(Array)
        req.outputs.first.should be_a(Hash)
        req.outputs.first["id"].should == 1
        req.outputs.first["result"].should be_a(Integer)
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
