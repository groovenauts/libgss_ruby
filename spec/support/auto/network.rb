def new_network(player_id = "1000001")
  new_network_with_options({}, player_id)
end

def new_network_with_options(opts={}, player_id = "1000001")
  config = YAML.load_file(File.expand_path("../../../../fontana_sample/config/app_garden.yml", __FILE__))
  opts = {
    device_type_cd: 1,
    client_version: "2013073101",
    consumer_secret: config["consumer_secret"],
    player_id: player_id,
    # ssl_disabled: true,
    url: "http://localhost:4000",
  }.update(opts)
  url = opts.delete(:url)
  Libgss::Network.new(url, opts)
end
