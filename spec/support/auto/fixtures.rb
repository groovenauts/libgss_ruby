
# see https://github.com/tengine/fontana/pull/3
require 'httpclient'
def request_fixture_load(fixture_name)
  c = HTTPClient.new
  res = c.post("http://localhost:4000/libgss_test/fixture_loadings/#{fixture_name}.json", "_method" => "put")
  raise "#{res.code} #{res.http_body.content}" unless res.code.to_s =~ /\A2\d\d\Z/
end

def fixtures(name)
  before do
    request_fixture_load(name)
  end
end
