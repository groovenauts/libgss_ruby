# -*- coding: utf-8 -*-
module Libgss
  class AssetRequest

    STATUS_PREPARING = 0
    STATUS_SENDING   = 1
    STATUS_WAITING   = 2
    STATUS_RECEIVED  = 3
    STATUS_SUCCESS   = 4
    STATUS_ERROR     = 5
    STATUS_TIMEOUT   = 6

    attr_reader :url, :status, :response_data

    # コンストラクタ
    def initialize(httpclient, url)
      @httpclient = httpclient
      @url = url
      @response_data = nil
      @status = STATUS_PREPARING
    end

    def send_request(&callback)
      res = @httpclient.get(url)
      @response_data = res.body
      callback.call(@response_data) if callback
    end
  end
end
