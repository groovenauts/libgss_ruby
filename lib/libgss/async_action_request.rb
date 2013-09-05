# -*- coding: utf-8 -*-
require 'libgss'

require 'net/http'
require 'uri'

module Libgss

  class AsyncActionRequest < ActionRequest

    attr_reader :ids
    attr_accessor :action_id

    # アクション群を実行するために実際にHTTPリクエストを送信します。
    def send_request(&callback)
      res = @httpclient.post(action_url, {"inputs" => @actions.map(&:to_hash)}.to_json, req_headers)
      case res.code.to_i
      when 200..299 then # OK
      else
        raise Error, "failed to send action request: [#{res.code}] #{res.body}"
      end
      r = JSON.parse(res.body)
      # puts res.body
      @outputs = Outputs.new(r["outputs"])
      callback.call(@outputs) if callback

      @ids = @outputs.map do |output|
        output['id']
      end

      @outputs
    end

    def async_status()
      raise Error, "failed to get response. please exec send_request before call." unless @ids

      res = @httpclient.get(action_url, {input_ids: @ids.join(',')}, req_headers)
      case res.code.to_i
      when 200..299 then # OK
      else
        raise Error, "failed to send action request: [#{res.code}] #{res.body}"
      end
      r = JSON.parse(res.body)
    end
  end
end
