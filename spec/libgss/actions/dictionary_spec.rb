# -*- coding: utf-8 -*-
require 'spec_helper'

describe Libgss::ActionRequest do

  let(:network){ new_network }

  let(:request) do
    network.login
    network.new_action_request
  end


  shared_examples_for "Libgss::ActionRequest#get_by_dictionary" do |input, output, conditions|
    [:get_dictionary, :get_by_dictionary].each do |action|
      describe "##{action}" do
      it do
        callback_called = false
        request.send(action, "ArmorUpgrade1", input, conditions)
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

    it_should_behave_like "Libgss::ActionRequest#get_by_dictionary", 10001, 10002, nil
    it_should_behave_like "Libgss::ActionRequest#get_by_dictionary", 10002, 10004, nil

    it_should_behave_like "Libgss::ActionRequest#get_by_dictionary", 10001, nil, {"input$gt" => 10003}
    it_should_behave_like "Libgss::ActionRequest#get_by_dictionary", 10002, nil, {"input$gt" => 10003}

end
