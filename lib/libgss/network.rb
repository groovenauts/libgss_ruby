# -*- coding: utf-8 -*-
require 'libgss'

require 'httpclient'
require 'json'
require 'uri'
require 'tengine/support/yaml_with_erb'
require 'tengine/support/core_ext/hash/keys'

require 'uuid'

module Libgss

  class Network

    Error = Libgss::Error

    attr_reader :base_url
    attr_reader :ssl_base_url
    attr_reader :ssl_disabled

    attr_reader :auth_token, :signature_key

    attr_accessor :consumer_secret
    attr_accessor :consumer_key
    attr_accessor :ignore_oauth_nonce
    attr_accessor :oauth_nonce
    attr_accessor :oauth_timestamp

    attr_accessor :api_version
    attr_accessor :platform
    attr_accessor :player_id
    attr_accessor :player_info
    attr_accessor :public_asset_url_prefix
    attr_accessor :public_asset_url_suffix

    attr_accessor :client_version
    attr_accessor :device_type_cd

    attr_accessor :skip_verifying_signature

    PRODUCTION_HTTP_PORT  =  80
    PRODUCTION_HTTPS_PORT = 443

    DEFAULT_HTTP_PORT  = (ENV['DEFAULT_HTTP_PORT' ] ||  80).to_i
    DEFAULT_HTTPS_PORT = (ENV['DEFAULT_HTTPS_PORT'] || 443).to_i

    # Libgss::Networkのコンストラクタです。
    #
    # @param [String] base_url_or_host 接続先の基準となるURLあるいはホスト名
    # @param [Hash] options オプション
    # @option options [String]  :platform 接続先のGSSサーバの認証のプラットフォーム。デフォルトは"fontana"。
    # @option options [String]  :api_version APIのバージョン。デフォルトは "1.0.0"
    # @option options [String]  :player_id 接続に使用するプレイヤのID
    # @option options [Hash]    :player_info pf_player_info として格納されるはずの諸情報
    # @option options [String]  :consumer_secret GSSサーバとクライアントの間で行う署名の検証に使用される文字列。
    # @option options [Boolean] :ignore_oauth_nonce OAuth認証時にoauth_nonceとoauth_timestampを使用しないかどうか。
    # @option options [String]  :oauth_nonce OAuth認証のoauth_nonceパラメータ
    # @option options [Integer] :oauth_timestamp OAuth認証のoauth_timestampパラメータ
    # @option options [Boolean] :ssl_disabled SSLを無効にするかどうか。
    # @option options [Boolean] :ignore_signature_key シグネチャキーによる署名を無視するかどうか
    # @option options [Boolean] :skip_verifying_signature レスポンスのシグネチャキーによる署名の検証をスキップするかどうか
    # @option options [Integer] :device_type_cd GSS/fontanaに登録されたデバイス種別
    # @option options [String]  :client_version GSS/fontanaに登録されたクライアントリリースのバージョン
    # @option options [Integer] :https_port HTTPSで接続する際の接続先のポート番号
    def initialize(base_url_or_host, options = {})
      if base_url_or_host =~ URI.regexp
        @base_url = base_url_or_host.sub(/\/\Z/, '')
        uri = URI.parse(@base_url)
      else
        if config_path = search_file(".libgss.yml")
          config = YAML.load_file_with_erb(config_path)
          options = config[base_url_or_host.to_s].deep_symbolize_keys.update(options)
        end
        uri = URI::Generic.build({scheme: "http", host: base_url_or_host, port: DEFAULT_HTTP_PORT}.update(options))
        @base_url = uri.to_s
      end
      @ssl_base_url = build_https_url(uri, options[:https_port])
      @ssl_disabled = options.delete(:ssl_disabled)
      @ssl_base_url = @base_url if @ssl_disabled
      @platform  = options[:platform] || "fontana"
      @api_version = options[:api_version] || "1.0.0"
      @player_id = options[:player_id]
      @player_info = options[:player_info] || {}

      @consumer_secret = options[:consumer_secret] || ENV["CONSUMER_SECRET"]
      @ignore_signature_key = !!options[:ignore_signature_key]
      @ignore_oauth_nonce = !!options[:ignore_oauth_nonce]
      @oauth_nonce = options[:oauth_nonce] || nil
      @oauth_timestamp = options[:oauth_timestamp] || nil

      @device_type_cd = options[:device_type_cd]
      @client_version = options[:client_version]

      @skip_verifying_signature = options[:skip_verifying_signature]

      @httpclient = HTTPClient.new
      @httpclient.ssl_config.verify_mode = nil # 自己署名の証明書をOKにする

      load_app_garden
    end

    def search_file(basename)
      dirs = [".", "./config", ENV['HOME']].join(",")
      Dir["{#{dirs}}/#{basename}"].select{|path| File.readable?(path)}.first
    end
    private :search_file

    def inspect
      r = "#<#{self.class.name}:#{self.object_id} "
      fields = (instance_variables - [:@httpclient]).map{|f| "#{f}=#{instance_variable_get(f).inspect}"}
      r << fields.join(", ") << ">"
    end

    # GSSサーバに接続してログインの検証と処理を行います。
    #
    # @param [Hash] extra オプション
    # @option extra [Integer] :device_type デバイス種別
    # @option extra [Integer] :device_id デバイス識別子
    # @return [Integer, false, Error] 基本的にサーバが返したレスポンスのステータスを返しますが、200番台でも検証に失敗した場合などは、falseあるいは例外オブジェクトを返します。
    def login_and_status(extra = {})
      @player_info[:id] = player_id
      @player_info.update(extra)
      # attrs = @player_info.each_with_object({}){|(k,v), d| d[ "player[#{k}]" ] = v }
      json = {"player" => @player_info}.to_json
      res = Libgss.with_retry("login") do
        @httpclient.post(login_url, json, req_headers)
      end
      process_json_response(res) do |obj|
        @player_id ||= obj["player_id"]
        @auth_token = obj["auth_token"]
        @signature_key = obj["signature_key"]
        !!@auth_token && !!@signature_key
      end
    end

    # GSSサーバに接続してログインの検証と処理を行います。
    #
    # @param [Hash] extra オプション
    # @option extra [Integer] :device_type デバイス種別
    # @option extra [Integer] :device_id デバイス識別子
    # @return [Boolean] ログインに成功した場合はtrue、失敗した場合はfalse
    def login(extra = {})
      case login_and_status(extra)
      when 200...300 then true
      else false
      end
    end

    # GSSサーバに接続してログインの検証と処理を行います。
    #
    # @param [Hash] extra オプション
    # @see #login
    # @return ログインに成功した場合は自身のオブジェクト返します。失敗した場合はLibgss::Network::Errorがraiseされます。
    def login!(extra = {})
      result = login_and_status(extra)
      case result
      when 200...300 then return self
      when ErrorResponse then raise result
      else raise Error, "Login Failure"
      end
    end

    # @return [Boolean] コンストラクタに指定されたignore_signature_keyを返します
    def ignore_signature_key?
      @ignore_signature_key
    end

    # @return [Boolean] コンストラクタに指定されたskip_verifying_signatureを返します
    def skip_verifying_signature?
      @skip_verifying_signature
    end

    # load_player_id メソッドをオーバーライドした場合に使用することを想定しています。
    # それ以外の場合は使用しないでください。
    def setup
      load_player_id
      login
    end

    # @return [Libgss::ActionRequest] アクション用リクエストを生成して返します
    def new_action_request
      ActionRequest.new(self, action_url, req_headers)
    end

    # @return [Libgss::AsyncActionRequest] 非同期アクション用リクエストを生成して返します
    def new_async_action_request
      AsyncActionRequest.new(self, async_action_url, async_result_url, req_headers)
    end

    # @return [Libgss::AssetRequest] 公開アセットを取得するリクエストを生成して返します
    def new_public_asset_request(asset_path)
      AssetRequest.new(@httpclient, public_asset_url(asset_path), req_headers)
    end

    # @return [Libgss::AssetRequest] 保護付きアセットを取得するリクエストを生成して返します
    def new_protected_asset_request(asset_path)
      AssetRequest.new(@httpclient, protected_asset_url(asset_path), req_headers)
    end

    # @param [String] path 対象となるapp_garden.ymlへのパス。デフォルトは "config/app_garden.yml" あるいは "config/app_garden.yml.erb"
    # @return [Libgss::Network] selfを返します。
    def load_app_garden(path = nil)
      if path
        raise ArgumentError, "file not found config/app_garden.yml* at #{Dir.pwd}" unless File.readable?(path)
      else
        path = search_file("app_garden.yml")
        return self unless path
      end
      # hash = YAML.load_file_with_erb(path, binding: binding) # tengine_supportが対応したらこんな感じで書きたい
      puts "loading #{path}"
      erb = ERB.new(IO.read(path))
      erb.filename = path
      text = erb.result(binding) # Libgss::FontanaをFontanaとしてアクセスできるようにしたいので、このbindingの指定が必要です
      hash = YAML.load(text)

      self.consumer_secret = hash["consumer_secret"]
      if platform = hash["platform"]
        name = (platform["name"] || "").strip
        unless name.empty?
          self.platform = name
        end
      end
      return self
    end

    # device_idを生成します
    #
    # @param [Hash] options オプション
    # @option options [Integer] :device_type デバイス種別
    # @return [String] 生成したUUIDの文字列
    def generate_device_id(options = {device_type: 1})
      result = uuid_gen.generate
      player_info.update(options)
      player_info[:device_id] = result
      result
    end

    # device_idを設定します
    #
    # @param [String] device_id デバイスID
    # @param [Hash] options オプション
    # @option options [Integer] :device_type デバイス種別
    def set_device_id(device_id, options = {device_type: 1})
      if player_info[:device_id] = device_id
        player_info.update(options)
      end
    end

    def uuid_gen
      @uuid_gen ||= UUID.new
    end

    def httpclient_for_action
      @httpclient_for_action ||=
        @ignore_signature_key ? @httpclient :
        HttpClientWithSignatureKey.new(@httpclient, self)
    end

    private

    def req_headers
      {
        "Content-Type" => "application/json",
        "X-Device-Type" => device_type_cd,
        "X-Client-Version" => client_version,
      }
    end

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
      result = res.status
      case result
      when 200...300 then # OK
      when 300...600 then
        return ErrorResponse.build(res)
      else
        raise InvalidResponse.new(result, "invalid http status")
      end
      begin
        obj = JSON.parse(res.content)
        yield(obj)
        return result
      rescue JSON::ParserError => e
        $stderr.puts("\e[31m[#{e.class}] #{e.message}\n#{res.content}")
        return e
      end
    end

    def build_https_url(uri, port = nil)
      uri.scheme = "https"
      uri.port = port || (uri.port == PRODUCTION_HTTP_PORT ? PRODUCTION_HTTPS_PORT : uri.port + 1)
      uri.to_s
    end

    def registration_url
      @registration_url ||= ssl_base_url + "/platforms/#{platform}/registration.json"
    end

    def login_url
      @login_url ||= ssl_base_url + "/platforms/#{platform}/sign_in.json"
    end

    def action_url
      @action_url ||= base_url + "/api/#{api_version}/actions.json?auth_token=#{auth_token}"
    end

    def async_action_url
      @async_action_url ||= base_url + "/api/#{api_version}/async_actions.json?auth_token=#{auth_token}"
    end

    def async_result_url
      @async_result_url ||= base_url + "/api/#{api_version}/async_results.json?auth_token=#{auth_token}"
    end

    def public_asset_url(asset_path)
      "#{@public_asset_url_prefix}#{asset_path}#{@public_asset_url_suffix}"
    end

    def protected_asset_url(asset_path)
      path = URI.encode(asset_path) # パラメータとして渡されるのでURLエンコードする必要がある
      @action_url ||= base_url + "/api/#{api_version}/assets?path=#{path}&auth_token=#{auth_token}"
    end
  end

end
