# -*- coding: utf-8 -*-
require 'libgss'

require 'httpclient'
require 'json'
require 'uri'

module Libgss

  class Network

    API_VERSION = "1.0.0".freeze

    attr_reader :base_url
    attr_reader :ssl_base_url
    attr_reader :ssl_disabled

    attr_reader :auth_token, :signature_key

    attr_accessor :api_version
    attr_accessor :platform
    attr_accessor :player_id
    attr_accessor :public_asset_url_prefix
    attr_accessor :public_asset_url_suffix


    DEFAULT_HTTP_PORT = (ENV['DEFAULT_HTTP_PORT'] || 80).to_i
    DEFAULT_HTTPS_PORT = (ENV['DEFAULT_HTTPS_PORT'] || 443).to_i

    def initialize(base_url_or_host, options = {})
      @ssl_disabled = options.delete(:ssl_disabled)
      if base_url_or_host =~ URI.regexp
        @base_url = base_url_or_host
        uri = URI.parse(@base_url)
        @ssl_base_url = build_https_url(uri)
      else
        uri = URI::Generic.build({scheme: "http", host: base_url_or_host, port: DEFAULT_HTTP_PORT}.update(options))
        @base_url = uri.to_s
        @ssl_base_url = build_https_url(uri)
      end
      @ssl_base_url = @base_url if @ssl_disabled
      @platform = "fontana"
      @httpclient = HTTPClient.new
      @httpclient.ssl_config.verify_mode = nil # 自己署名の証明書をOKにする
    end

    def inspect
      r = "#<#{self.class.name}:#{self.object_id} "
      fields = (instance_variables - [:@httpclient]).map{|f| "#{f}=#{instance_variable_get(f).inspect}"}
      r << fields.join(", ") << ">"
    end

    def login
      raise "player_id is not set." if player_id.nil? || player_id.empty?
      res = @httpclient.post(login_url, "player[id]" => player_id)
      case res.status
      when 200...300 then # OK
      when 300...400 then return false # リダイレクト対応はしません
      when 400...500 then return false
      when 500...600 then return false
      else raise "invalid http status: #{res.status}"
      end
      begin
        obj = JSON.parse(res.content)
      rescue JSON::ParserError => e
        return false
      end
      @auth_token = obj["auth_token"]
      @signature_key = obj["signature_key"]
      true
    end

    def new_action_request
      ActionRequest.new(@httpclient, action_url)
    end

    def new_public_asset_request(asset_path)
      AssetRequest.new(@httpclient, public_asset_url(asset_path))
    end

    def new_protected_asset_request(asset_path)
      AssetRequest.new(@httpclient, protected_asset_url(asset_path))
    end

    private

    def build_https_url(uri)
      uri.scheme = "https"
      uri.port = DEFAULT_HTTPS_PORT
      uri.to_s
    end

    def login_url
      @login_url ||= ssl_base_url + "/platforms/#{platform}/sign_in.json"
    end

    def action_url
      @action_url ||= base_url + "/api/#{API_VERSION}/actions.json?auth_token=#{auth_token}"
    end

    def public_asset_url(asset_path)
      "#{@public_asset_url_prefix}#{asset_path}#{@public_asset_url_suffix}"
    end

    def protected_asset_url(asset_path)
      path = URI.encode(asset_path) # パラメータとして渡されるのでURLエンコードする必要がある
      @action_url ||= base_url + "/api/#{API_VERSION}/assets?path=#{path}&auth_token=#{auth_token}"
    end
  end

end
