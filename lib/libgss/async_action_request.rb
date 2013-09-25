# -*- coding: utf-8 -*-
require 'libgss'

require 'net/http'
require 'uri'

module Libgss

  class AsyncActionRequest < ActionRequest

    attr_reader :ids
    attr_accessor :action_id
    attr_accessor :result_url


    # コンストラクタ
    def initialize(httpclient, action_url, result_url, req_headers)
      super(httpclient, action_url, req_headers)
      @result_url = result_url
    end

    # アクション群を実行するために実際にHTTPリクエストを送信します。
    def send_request(&callback)
      res = network.httpclient_for_action.post(action_url, {"inputs" => @actions.map(&:to_hash)}.to_json, req_headers)
      r = process_response(res, :async_request)
      outputs = Outputs.new(r["outputs"])
      # callback.call(@outputs) if callback
      @ids = outputs.map{|output| output['id'] }
      outputs
    end

    def async_status(ids=nil, &callback)
      ids ||= @ids
      ids = [ids] unless ids.is_a?(::Array)
      raise Error, "failed to get response. please exec send_request before call." unless ids

      res = network.httpclient_for_action.post(result_url, {'input_ids' => ids}.to_json, req_headers)
      r = process_response(res, :aync_results)
      @outputs = Outputs.new(r["outputs"])
      callback.call(@outputs) if callback
      @outputs
    end
    alias :async_results :async_status
  end
end
