require 'libgss'

require 'oauth'

module Libgss
  class HttpClientWithSignatureKey

    attr_reader :impl, :network
    def initialize(impl, network)
      @impl, @network = impl, network
    end

    def post(uri, body, header, &block)
      headers = {
        "oauth_consumer_key" => network.consumer_key,
        "oauth_token"        => network.auth_token,
      }
      request = OAuth::RequestProxy.proxy(
        "method" => "post",
        "uri"    => url
        "parameters" => {"body" => body}.update(headers))
      headers["oauth_signatrue"] = OAuth::Signature.sign(
        request,
        :consumer_secret => network.consumer_secret,
        :token_secret    => network.signature_key)
      res = @impl.post(url, body, headers)
    end
  end
end
