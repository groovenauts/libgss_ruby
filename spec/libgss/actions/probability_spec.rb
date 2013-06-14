# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do

  let(:network){ new_network }

  let(:request) do
    network.login
    network.new_action_request
  end

  describe "#get_by_probability" do

    shared_examples_for "Libgss::ActionRequest#get_by_probability" do |value, conditions, result|
      it "#{value.inspect} with #{conditions.inspect} returns #{result.inspect}" do
        callback_called = false
        request.get_by_probability("Composition1", value, conditions)
        request.send_request do |outputs|
          callback_called = true
          outputs.length.should == 1
          obj = outputs.first["result"]
          # AppSeedで定義されているデータの確認
          obj.should == result
        end
        callback_called.should == true
      end
    end

    it_should_behave_like "Libgss::ActionRequest#get_by_probability", 10002, nil, 60
    it_should_behave_like "Libgss::ActionRequest#get_by_probability", 20007, nil, 20

    context "with conditions" do
      it_should_behave_like "Libgss::ActionRequest#get_by_probability", 20007, {"element" => { "20002" => 1, "20006" => 1 } }, 20
      it_should_behave_like "Libgss::ActionRequest#get_by_probability", 20007, {"element" => { "20002" => 1, "20006" => 2 } }, nil

      it_should_behave_like "Libgss::ActionRequest#get_by_probability", {"20002" => 2}, {"element" => { "20002" => 1, "20006" => 1 } }, 80
      it_should_behave_like "Libgss::ActionRequest#get_by_probability", {"20002" => 2}, {"element" => { "20002" => 1, "20006" => 2 } }, nil
    end
  end

  describe "#dice" do
    it do
      results = []
      10.times do
        request.dice("Composition1", {"element" => { "20002" => 1, "20006" => 1 } })
        request.send_request do |outputs|
          r = outputs.first["result"]
          case r
          when 20007, { "20002" => 2 } then # この２つの値以外はないはず
            results << r
          else
            raise "Unknown result #{r.inspect}"
          end
        end
      end
      # エーテルZ、ポーションA 2個
      ether_z, potion_a = results.partition{|r| r == 20007}
      ether_z.length.should >= 0
      ether_z.length.should <= 4
      potion_a.length.should >= 6
      potion_a.length.should <= 10

    end
  end
end
