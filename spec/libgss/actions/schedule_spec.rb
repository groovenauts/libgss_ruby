# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do

  let(:network){ new_network }

  let(:request) do
    network.login
    network.new_action_request
  end


  shared_examples_for "Libgss::ActionRequest#get_by_schedule" do |input, output, conditions|
    [:get_schedule, :get_by_schedule].each do |action|
      describe "##{action}" do
      it action do
        callback_called = false
        request.send(action, "ShopSchedule", input, conditions)
        request.send_request do |outputs|
          callback_called = true
          outputs.length.should == 1
          outputs.first["result"].should == output
        end
        callback_called.should == true
      end
      end
    end

  end

    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/09 00:00:00+09:00").to_i, "ShopMenu1", nil
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/10 11:59:59+09:00").to_i, "ShopMenu1", nil
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/10 12:00:00+09:00").to_i, "ShopMenu2", nil
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/15 12:00:00+09:00").to_i, "ShopMenu2", nil
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/20 12:59:59+09:00").to_i, "ShopMenu2", nil
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/20 13:00:00+09:00").to_i, "ShopMenu2", nil # 整数範囲テーブルと違って末尾にも含まれる
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/20 13:00:01+09:00").to_i, "ShopMenu1", nil

    cond = {"value$ne" => "ShopMenu2" }
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/09 00:00:00+09:00").to_i, "ShopMenu1", cond
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/10 11:59:59+09:00").to_i, "ShopMenu1", cond
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/10 12:00:00+09:00").to_i, "ShopMenu1", cond
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/15 12:00:00+09:00").to_i, "ShopMenu1", cond
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/20 12:59:59+09:00").to_i, "ShopMenu1", cond
    it_should_behave_like "Libgss::ActionRequest#get_by_schedule", Time.parse("2012/07/20 13:00:00+09:00").to_i, "ShopMenu1", cond

end
