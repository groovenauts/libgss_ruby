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

    attr_accessor :consumer_secret
    attr_accessor :consumer_key

    attr_accessor :api_version
    attr_accessor :platform
    attr_accessor :player_id
    attr_accessor :public_asset_url_prefix
    attr_accessor :public_asset_url_suffix

    attr_accessor :client_version
    attr_accessor :device_type_cd

    PRODUCTION_HTTP_PORT  =  80
    PRODUCTION_HTTPS_PORT = 443

    DEFAULT_HTTP_PORT  = (ENV['DEFAULT_HTTP_PORT' ] ||  80).to_i
    DEFAULT_HTTPS_PORT = (ENV['DEFAULT_HTTPS_PORT'] || 443).to_i

    # Libgss::Networkのコンストラクタです。
    #
    # @param [String] base_url_or_host 接続先の基準となるURLあるいはホスト名
    # @param [Hash] options オプション
    # @option options [String]  :platform 接続先のGSSサーバの認証のプラットフォーム。デフォルトは"fontana"。
    # @option options [String]  :player_id 接続に使用するプレイヤのID
    # @option options [String]  :consumer_secret GSSサーバとクライアントの間で行う署名の検証に使用される文字列。
    # @option options [Boolean] :ssl_disabled SSLを無効にするかどうか。
    # @option options [Boolean] :ignore_signature_key シグネチャキーによる署名を行うかどうか
    # @option options [Integer] :device_type_cd GSS/fontanaに登録されたデバイス種別
    # @option options [String]  :client_version GSS/fontanaに登録されたクライアントリリースのバージョン
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
      @platform  = options[:platform] || "fontana"
      @player_id = options[:player_id]

      @consumer_secret = options[:consumer_secret] || ENV["CONSUMER_SECRET"]
      @ignore_signature_key = !!options[:ignore_signature_key]

      @device_type_cd = options[:device_type_cd]
      @client_version = options[:client_version]

      @httpclient = HTTPClient.new
      @httpclient.ssl_config.verify_mode = nil # 自己署名の証明書をOKにする
    end

    def inspect
      r = "#<#{self.class.name}:#{self.object_id} "
      fields = (instance_variables - [:@httpclient]).map{|f| "#{f}=#{instance_variable_get(f).inspect}"}
      r << fields.join(", ") << ">"
    end

    def req_headers
      {
        "X-Device-Type" => device_type_cd,
        "X-Client-Version" => client_version,
      }
    end

    # GSSサーバに接続してログインの検証と処理を行います。
    #
    # @param [String] base_url_or_host 接続先の基準となるURLあるいはホスト名
    # @param [Hash] options オプション
    # @option options [String]  :platform 接続先のGSSサーバの認証のプラットフォーム。デフォルトは"fontana"。
    # @return [Boolean] ログインに成功した場合はtrue、失敗した場合はfalse
    def login(extra = {})
      retry_count = 0
      begin
      attrs = { "player[id]" => player_id }
      extra.each{|k, v| attrs[ "player[#{k}]" ] = v }
      res = @httpclient.post(login_url, attrs, req_headers)
      process_json_response(res) do |obj|
        @player_id ||= obj["player_id"]
        @auth_token = obj["auth_token"]
        @signature_key = obj["signature_key"]
        !!@auth_token && !!@signature_key
      end
      rescue OpenSSL::SSL::SSLError => e
        $stderr.puts("retrying login [#{e.class.name}] #{e.message}")
        sleep(0.2)
        retry_count += 1
        retry if retry_count > 3
        raise e
      end
    end

    def ignore_signature_key?
      @ignore_signature_key
    end

    def setup
      load_player_id
      login
    end

    def new_action_request
      ActionRequest.new(httpclient_for_action, action_url, req_headers)
    end

    def new_async_action_request
      AsyncActionRequest.new(httpclient_for_action, aync_action_url, req_headers)
    end

    def new_public_asset_request(asset_path)
      AssetRequest.new(@httpclient, public_asset_url(asset_path), req_headers)
    end

    def new_protected_asset_request(asset_path)
      AssetRequest.new(@httpclient, protected_asset_url(asset_path), req_headers)
    end

    def httpclient_for_action
      @httpclient_for_action ||=
        @ignore_signature_key ? @httpclient :
        HttpClientWithSignatureKey.new(@httpclient, self)
    end

    private

    # ストレージからplayer_idをロードします
    # 保存されていたらtrueを、保存されていなかったらfalseを返します。
    #
    # ストレージは、cocos2d-x ならば CCUserDefault のようにデータを永続化するものを指します。
    #     http://www.cocos2d-x.org/reference/native-cpp/d0/d79/classcocos2d_1_1_c_c_user_default.html
    #
    # ただし、libgss-rubyはテスト用なので毎回違うplayer_idを使います。
    # もし保存したい場合は、別途ファイルなどに記録してください。
    def load_player_id
      return false
    end

    def process_json_response(res)
      case res.status
      when 200...300 then # OK
      when 300...400 then return false # リダイレクト対応はしません
      when 400...500 then return false
      when 500...600 then return false
      else raise "invalid http status: #{res.status}"
      end
      begin
        obj = JSON.parse(res.content)
        return yield(obj)
      rescue JSON::ParserError => e
        return false
      end
    end

    def build_https_url(uri)
      uri.scheme = "https"
      uri.port = (uri.port == PRODUCTION_HTTP_PORT) ? PRODUCTION_HTTPS_PORT : uri.port + 1
      uri.to_s
    end

    def registration_url
      @registration_url ||= ssl_base_url + "/platforms/#{platform}/registration.json"
    end

    def login_url
      @login_url ||= ssl_base_url + "/platforms/#{platform}/sign_in.json"
    end

    def action_url
      @action_url ||= base_url + "/api/#{API_VERSION}/actions.json?auth_token=#{auth_token}"
    end

    def aync_action_url
      @async_action_url ||= base_url + "/api/#{API_VERSION}/async_actions.json?auth_token=#{auth_token}"
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
