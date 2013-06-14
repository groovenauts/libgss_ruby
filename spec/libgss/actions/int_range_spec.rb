# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do

  let(:network){ new_network }

  let(:request) do
    network.login
    network.new_action_request
  end


  describe "#get_by_int_range" do
    shared_examples_for "Libgss::ActionRequest#get_by_int_range" do |input, output, conditions|
      it do
        callback_called = false
        request.get_by_int_range("RequiredExperience", input, conditions)
        request.send_request do |outputs|
          callback_called = true
          outputs.length.should == 1
          outputs.first["result"].should == output
        end
        callback_called.should == true
      end
    end

    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",   0,  1, nil
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",   9,  1, nil
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",  10,  2, nil
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",  24,  2, nil
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",  25,  3, nil

    cond = {"value$gte" => 10 }
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",   0, nil, cond
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",   9, nil, cond
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",  10, nil, cond
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",  24, nil, cond
    it_should_behave_like "Libgss::ActionRequest#get_by_int_range",  25, nil, cond
  end

end
