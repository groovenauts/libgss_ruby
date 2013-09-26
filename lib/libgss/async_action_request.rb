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
    def send_request
      res = network.httpclient_for_action.post(action_url, {"inputs" => @actions.map(&:to_hash)}.to_json, req_headers)
      response_hook.call(res) if response_hook # テストでレスポンスを改ざんを再現するために使います
      r = process_response(res, :async_action_request)
      @outputs = Outputs.new(r["outputs"])
      @ids = @outputs.map{|output| output['id'] }
      @outputs
    end

    def async_status(ids=nil)
      ids ||= @ids
      ids = [ids] unless ids.is_a?(::Array)
      raise Error, "failed to get response. please exec send_request before call." unless ids

      res = network.httpclient_for_action.post(result_url, {'input_ids' => ids}.to_json, req_headers)
      response_hook.call(res) if response_hook # テストでレスポンスを改ざんを再現するために使います
      r = process_response(res, :aync_results_request)
      @outputs = Outputs.new(r["outputs"]) # Outputsを使うことでidによるアクセスを可能に
    end
    alias :async_results :async_status
  end
end
