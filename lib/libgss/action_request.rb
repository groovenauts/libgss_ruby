# -*- coding: utf-8 -*-
require 'libgss'

require 'net/http'
require 'uri'

module Libgss

  class ActionRequest

    class Error < StandardError
    end

    class SignatureError < Error
    end

    STATUS_PREPARING = 0
    STATUS_SENDING   = 1
    STATUS_WAITING   = 2
    STATUS_RECEIVED  = 3
    STATUS_SUCCESS   = 4
    STATUS_ERROR     = 5
    STATUS_TIMEOUT   = 6


    # 読み込みのみ、書き込み不可
    attr_reader :network
    attr_reader :action_url, :req_headers
    attr_reader :status, :outputs

    attr_accessor :response_hook

    # コンストラクタ
    def initialize(network, action_url, req_headers)
      @network = network
      @action_url = action_url
      @req_headers = req_headers
      @status = STATUS_PREPARING
      @actions = []
      @action_id = 0;
    end

    def inspect
      r = "#<#{self.class.name}:#{self.object_id} "
      fields = (instance_variables - [:@network]).map{|f| "#{f}=#{instance_variable_get(f).inspect}"}
      r << fields.join(", ") << ">"
    end

    def next_action_id
      @action_id += 1
    end

    def add_action(hash)
      action = Action.new(next_action_id, hash)
      @actions << action
      action
    end

    # アクション群を実行するために実際にHTTPリクエストを送信します。
    def send_request(&callback)
      res = Libgss.with_retry("action_request") do
        network.httpclient_for_action.post(action_url, {"inputs" => @actions.map(&:to_hash)}.to_json, req_headers)
      end
      response_hook.call(res) if response_hook # テストでレスポンスを改ざんを再現するために使います
      r = process_response(res, :action_request)
      @outputs = Outputs.new(r["outputs"])
      callback.call(@outputs) if callback
      @outputs
    end

    # レスポンスの処理を行います
    def process_response(res, req_type)
      case res.status.to_i
      when 200..299 then # OK
      else
        # raise Error, "failed to send #{req_type}: [#{res.status}] #{res.content}"
        raise ErrorResponse.build(res)
      end
      verify_signature(res) do |content|
        begin
          JSON.parse(content)
        rescue JSON::ParserError => e
          $stderr.puts("\e[31m[#{e.class}] #{e.message}\e[0m\n#{content}")
          raise e
        end
      end
    end
    private :process_response

    # シグネチャの検証を行います
    def verify_signature(res, &block)
      case network.api_version
      when "1.0.0" then verify_signature_on_headers(res, &block)
      when "1.1.0" then verify_signature_included_body(res, &block)
      else
        raise Error, "Unsupported API version: #{network.api_version}"
      end
    end

    private

    # ヘッダから検証のための諸情報を取得します。
    # キーの名前がbodyのJSONから取得する場合と微妙に違っているので注意してください。
    def verify_signature_on_headers(res, &block)
      content = res.content
      attrs = {
        content:      content,
        consumer_key: res.headers["Res-Sign-Consumer-Key"] || "",
        nonce:        res.headers["Res-Sign-Nonce"],
        timestamp:    res.headers["Res-Sign-Timestamp"],
      }
      verify_signature_by_oauth(res.headers["Res-Sign-Signature"], attrs, &block)
    end

    # bodyのJSONから検証のための諸情報を取得します。
    # キーの名前がヘッダから取得する場合と微妙に違っているので注意してください。
    def verify_signature_included_body(res, &block)
      resp = nil
      begin
        resp = JSON.parse(res.content)
      rescue JSON::ParserError => e
        $stderr.puts("\e[31m[#{e.class}] #{e.message}\e[0m\n#{res.content}")
        raise e
      end
      content = resp["body"]
      attrs = {
        content:      content,
        consumer_key: resp["res_sign_consumer_key"] || "",
        nonce:        resp["res_sign_nonce"],
        timestamp:    resp["res_sign_timestamp"],
      }
      verify_signature_by_oauth(resp["res_sign_signature"], attrs, &block)
    end

    def verify_signature_by_oauth(signature, attrs)
      if network.skip_verifying_signature?
        return yield(attrs[:content]) if block_given?
      end
      res_hash = {
        "uri" => "",
        "method" => "",
        "parameters" => {
          "body" => attrs[:content],
          "oauth_consumer_key" => attrs[:consumer_key],
          "oauth_token" => network.auth_token,
          "oauth_signature_method" => "HMAC-SHA1",
          "oauth_nonce" => attrs[:nonce],
          "oauth_timestamp" => attrs[:timestamp]
        }
      }
      s = OAuth::Signature.build(res_hash){ [ network.signature_key, network.consumer_secret] }
      # puts "res_hash: " << res_hash.inspect
      # puts "signature_key: " << network.signature_key.inspect
      # puts "consumer_secret: " << network.consumer_secret.inspect
      # puts "signature_base_string: " << s.signature_base_string
      unless signature == s.signature
        raise SignatureError, "invalid signature or something"
      end
      return yield(attrs[:content]) if block_given?
    end

    public

    # 条件に該当するデータを取得
    # @param [String] name 対象となるコレクション名
    # @param [Hash] conditions 検索条件
    # @param [Array<Array<String, Integer>>] order フィールド名と(1 or -1)の組み合わせの配列
    # @return [Array<Libgss::JsonObject>]該当したデータを表すJSONオブジェクトの配列
    def find_all(name, conditions = nil, order = nil)
      args =  {action: "all", name: name}
      args[:conditions] = conditions if conditions
      args[:order] = order if order
      add_action(args)
    end
    alias_method :all, :find_all

    # ページネーション付きで条件に該当するデータを取得
    # @param [String] name 対象となるコレクション名
    # @param [String] page 取得するページ
    # @param [String] per_page 1ページあたりの件数
    # @param [Hash] conditions 検索条件
    # @param [Array<Array<String, Integer>>] order フィールド名と(1 or -1)の組み合わせの配列
    # @return [Array<Libgss::JsonObject>]該当したデータを表すJSONオブジェクトの配列
    def paginate(name, page, per_page, conditions = nil, order = nil)
      args =  {action: "all", name: name, page: page, per_page: per_page}
      args[:conditions] = conditions if conditions
      args[:order] = order if order
      add_action(args)
    end

    # 条件に該当するデータを取得
    # @param [String] name 対象となるコレクション名
    # @param [Hash] conditions 検索条件
    # @return [Integer] 該当したデータの件数
    def count(name, conditions = nil)
      args =  {action: "count", name: name}
      args[:conditions] = conditions if conditions
      add_action(args)
    end

    # 条件に該当するデータを１件だけ取得
    # @param [String] name 対象となるコレクション名
    # @param [Hash] conditions 検索条件
    # @param [Array<Array<String, Integer>>] order フィールド名と(1 or -1)の組み合わせの配列
    # @return [Libgss::JsonObject] 該当したデータを表すJSONオブジェクト
    def find_first(name, conditions = nil, order = nil)
      args =  {action: "first", name: name}
      args[:conditions] = conditions if conditions
      args[:order] = order if order
      add_action(args)
    end
    alias_method :first, :find_first

    # 辞書テーブルからinputに対応するoutputの値を返します。
    # @param [String] name 対象となる辞書のコレクション名
    # @param [String] input 入力オブジェクトの文字列表現
    # @param [Hash] conditions 検索条件
    # @return [Object] outputの値を示すJSONオブジェクト
    def get_by_dictionary(name, input, conditions = nil)
      args = {action: "get", name: name, input: input}
      args[:conditions] = conditions if conditions
      add_action(args)
    end
    alias_method :get_dictionary, :get_by_dictionary

    # 期間テーブルからinputに対応するoutputの値を返します。
    # @param [String] name 対象となる機関テーブルのコレクション名
    # @param [Integer] time 対象となるUNIX時刻
    # @param [Hash] conditions 検索条件
    # @return [Object] outputの値を示すJSONオブジェクト
    def get_by_schedule(name, time = Time.now.to_i, conditions = nil)
      args = {action: "get", name: name, time: time}
      args[:conditions] = conditions if conditions
      add_action(args)
    end
    alias_method :get_schedule, :get_by_schedule

    # 整数範囲テーブルからinputに対応するoutputの値を返します。
    # @param [String] name 対象となる整数範囲テーブルのコレクション名
    # @param [Integer] input 対象となる入力値
    # @param [Hash] conditions 検索条件
    # @return [Object] outputの値を示すJSONオブジェクト
    def get_by_int_range(name, input, conditions = nil)
      args = {action: "get", name: name, input: input}
      args[:conditions] = conditions if conditions
      add_action(args)
    end
    alias_method :get_int_range, :get_by_int_range

    # 確率テーブルからinputに対応するoutputの値を返します。
    # diceがあるのであまり使われないはず。
    #
    # @param [String] name 対象となる確率テーブルのコレクション名
    # @param [String] value 対象となるオブジェクトの文字列表現
    # @param [Hash] conditions 検索条件
    # @return [Object] valueの値を示すJSONオブジェクト
    def get_by_probability(name, value, conditions = nil)
      args = {action: "get", name: name, value: value}
      args[:conditions] = conditions if conditions
      add_action(args)
    end
    alias_method :get_probability, :get_by_probability

    # プレイヤーからplayer_idに対応するプレイヤーを返します
    #
    # @param [String] name 対象となるコレクション名
    # @param [String] player_id 対象となるplayer_id
    # @param [Hash] conditions 検索条件
    # @return [Object] プレイヤーを表すJSONオブジェクト
    def get_by_player(name = "Player", player_id = nil)
      args =  {action: "get"}
      args[:name] = name if name
      args[:player_id] = player_id.to_s if player_id
      add_action(args)
    end
    alias_method :get_player, :get_by_player

    # ゲームデータからplayer_idに対応するゲームデータを返します
    #
    # @param [String] name 対象となるコレクション名
    # @param [String] player_id 対象となるplayer_id
    # @param [Hash] conditions 検索条件
    # @return [Object] ゲームデータを表すJSONオブジェクト
    def get_by_game_data(name = "GameData", player_id = nil)
      args =  {action: "get"}
      args[:name] = name if name
      args[:player_id] = player_id.to_s if player_id
      add_action(args)
    end
    alias_method :get_game_data, :get_by_game_data




    # ログあるいは履歴を登録します。
    #
    # @param [String] name 対象となるコレクション名
    # @param [Hash] attrs 属性
    # @return
    def create(name, attrs)
      args =  {action: "create", name: name, attrs: attrs}
      add_action(args)
    end

    # プレイヤー、ゲームデータを更新します。
    # @param [String] name 対象となるコレクション名
    # @param [Hash] player_id 対象を特定するためのID。
    # @param [Hash] attrs 属性。対象を特定するためのplayer_idを含みません。
    # @return
    def update(name, attrs, player_id = nil)
      args =  {action: "update", name: name, attrs: attrs}
      args[:player_id] = player_id.to_s if player_id
      add_action(args)
    end


    # 確率テーブルに従って、発生させた乱数から得られた値
    # @param [String] name 対象となるコレクション名
    # @param [Hash] conditions 検索条件
    # @return [Object] 確率テーブルの値
    def dice(name, conditions = nil)
      args = {action: "dice", name: name}
      args[:conditions] = conditions if conditions
      add_action(args)
    end

    # ストアドスクリプトを実行します。
    # @param [String] name 対象となるコレクション名
    # @param [Hash] key 対象となるスクリプトのキー
    # @param [Hash] args スクリプトに渡す引数
    # @return [Object] ストアドスクリプトの結果
    def execute(name, key, args = nil)
      action_args = {action: "execute", name: name, key: key}
      action_args[:args] = args if args
      add_action(action_args)
    end



    # サーバの現在時刻を返します。
    # @return [Time] 現在時刻を表すUNIX時刻
    def server_time()
      add_action(action: "server_time")
    end

    # 引数timeに指定された時刻の運用日付を返します。
    # 「運用日付」とは AppGarden の[ゲーム内日付変更時刻]で
    # 設定された時刻を日付の開始時刻とした場合の日付(Ruby
    # ストアドスクリプト内ではDateオブジェクト)を返します。
    #
    # @param [Time] time time に指定された時刻(省略時は現在時刻)の運用日付
    # @return [Date] timeが属する運用日付
    def server_date(time = nil)
      args = {action: "server_date"}
      args[:time] = time if time
      add_action(args)
    end



    # # フレンドシップを更新します。
    # # @param [String] name 対象となるコレクション名
    # # @param [Hash] attrs 属性。対象を特定するためのIDを含みます。
    # # @return
    # def update_friendship(name, attrs)
    # end

    # # フレンドシップを削除します。
    # # @param [String] name 対象となるコレクション名
    # # @param [Hash] target 対象となるフレンドのID
    # # @return
    # def delete_friendship(name, target)
    # end

    # フレンドシップを申請をします。
    # @param [String] name 対象となるコレクション名
    # @param [Hash] target 対象となるフレンドのID
    # @return
    def apply(name, target)
      args = {action: "apply", name: name, target: target}
      add_action(args)
    end

    # フレンドシップの申請を承認します。
    # @param [String] name 対象となるコレクション名
    # @param [Hash] target 対象となるフレンドのID
    # @return
    def approve(name, target)
      args = {action: "approve", name: name, target: target}
      add_action(args)
    end

    # フレンドシップの申請のキャンセル、申請却下、フレンド解除をします。
    # @param [String] name 対象となるコレクション名
    # @param [Hash] target 対象となるフレンドのID
    # @return
    def breakoff(name, target)
      args = {action: "breakoff", name: name, target: target}
      add_action(args)
    end

    # フレンドをブロック（ブラックリスト追加）します。
    # @param [String] name 対象となるコレクション名
    # @param [Hash] target 対象となるフレンドのID
    # @return
    def block(name, target)
      args = {action: "block", name: name, target: target}
      add_action(args)
    end

    # フレンドをブロックの解除（ブラックリストから除外）します。
    # @param [String] name 対象となるコレクション名
    # @param [Hash] target 対象となるフレンドのID
    # @return
    def unblock(name, target)
      args = {action: "unblock", name: name, target: target}
      add_action(args)
    end


    # マスタの差分を取得します
    # @param [Hash] downloaded_versions キーが対象となるコレクション名、値がそのバージョンを示すHash
    # @return 差分コレクション毎の差分を示すHashの配列
    def master_diffs(downloaded_versions)
      args = {action: "master_diffs", downloaded_versions: downloaded_versions}
      add_action(args)
    end

  end

end
