$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'libgss'

# see https://github.com/tengine/fontana/pull/3
require 'httpclient'
def request_fixture_load(fixture_name)
  c = HTTPClient.new
  c.post("http://localhost:3000/libgss_test/fixture_loadings/#{fixture_name}.json", "_method" => "put")
end


def new_network(url = "http://localhost:3000", player_id = "1000001")
  network = Libgss::Network.new(url)
  network.player_id = player_id
  network.consumer_secret = "cpqomf5gs4ob6prd5w5zd52yg9du7150"
  network
end
