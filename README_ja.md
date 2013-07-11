# libgss-ruby

libgss-rubyはGroovenautsのGSS用通信ライブラリです。

通常、GSSと通信するためには、直接HTTPのAPIをコールするか、それぞれの環境に合わせた
通信ライブラリを用いる必要があります。

しかしこのlibgss-rubyとRSpecやminitestなどを組み合わせることによって、GSSにおける
サーバーサイドスクリプトであるストアドスクリプトのユニットテストを記述することが
できます。

## インストール方法

以下の２つの方法があります。プロジェクトを作成してGemfileが定義されている場合は、bundlerを使う方法をおすすめします。
それ以外の場合は、手動でインストールする方法でインストールしてください。


### プロジェクトを作ってbundlerを使う方法

アプリケーションのGemfileに以下の行を追加します:

    gem 'libgss'

以下の行を実行します:

    $ bundle


### 手動でインストールする方法

手動で以下のコマンドを実行してインストールできます:

```
$ gem install libgss
```

## irbでの使用方法

```
$ irb -r libgss

>> network = Libgss::Network.new("http://localhost:3000", ssl_disabled: true)
=> #<Libgss::Network:2152782140 @ssl_disabled=true, @base_url="http://localhost:3000", @ssl_base_url="http://localhost:3000", @platform="fontana">
>> network.player_id = "1000001"
=> "1000001"
>> network.login
=> true
>> 
?> req1 = network.new_action_request
=> #<Libgss::ActionRequest:2152568320 @action_url="http://localhost:3000/api/1.0.0/actions.json?auth_token=259rKDuSb3CT1UxbywAf", @status=0, @actions=[], @action_id=0>
>> req1.execute("ItemRubyStoredScript", "use_item", {"item_cd" => "20001"})
=> #<Libgss::Action:0x0000010092f7b0 @id=1, @args={:action=>"execute", :name=>"ItemRubyStoredScript", :key=>"use_item", :args=>{"item_cd"=>"20001"}}>
>> req1.get_by_game_data
=> #<Libgss::Action:0x000001008f9188 @id=2, @args={:action=>"get", :name=>"GameData"}>
>> req1.send_request
=> nil
>> 
?> req1.outputs
=> [{"result"=>"You don't have enough item", "id"=>1}, {"result"=>{"content"=>{"hp"=>15, "max_hp"=>15, "mp"=>5, "max_mp"=>5, "exp"=>100, "money"=>200, "items"=>{"20001"=>0, "20005"=>1}, "equipments"=>{"head"=>10018, "body"=>10012, "right_hand"=>10001, "left_hand"=>nil}}, "greeting_points"=>0, "login_bonus"=>[[10001, 1]], "invitation_code"=>nil, "invite_player"=>nil, "read_notifications"=>[]}, "id"=>2}]
>> 
?> req1.outputs.get(1)
=> {"result"=>"You don't have enough item", "id"=>1}
```

## 接続確認

上記のirbでの接続テストを1コマンドで実行できるように`gss-server-time`コマンドを用意しています。

```
$ gss-server-time http://localhost:3000 -a path/to/app_garden.yml.erb
```

あるいは

```
$ gss-server-time http://localhost:3000 -p fontana -c <consumer_secret> -i <player_id>
```

という風に使用します。詳しくは `gss-server-time --help` を参照してください。
