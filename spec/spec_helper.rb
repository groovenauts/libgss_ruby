$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'libgss'
require 'tengine/support/yaml_with_erb'

# see https://github.com/tengine/fontana/pull/3
require 'httpclient'
def request_fixture_load(fixture_name)
  c = HTTPClient.new
  c.post("http://localhost:3000/libgss_test/fixture_loadings/#{fixture_name}.json", "_method" => "put")
end


def new_network(url = "http://localhost:3000", player_id = "1000001")
  config = YAML.load_file(File.expand_path("../../fontana_sample/config/app_garden.yml", __FILE__))
  opts = {
    consumer_secret: config["consumer_secret"],
    player_id: player_id
  }
  Libgss::Network.new(url, opts)
end
