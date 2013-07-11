# Libgss

Network library for Groovenauts GSS.

Usually game developers use other network libraries built in each environment,
but can use this network library in oder to write test script about Stored Script
which is server side script in GSS.

## Installation

Add this line to your application's Gemfile:

    gem 'libgss'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libgss

## Usage

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


## connection testing

You can use `gss-server-time` command to test connection like this:

```
$ gss-server-time http://localhost:3000 -a path/to/app_garden.yml.erb
```

see `gss-server-time --help` for more options
