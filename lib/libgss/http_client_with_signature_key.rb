require 'libgss'

require 'oauth'

module Libgss
  class HttpClientWithSignatureKey

    attr_reader :impl, :network
    def initialize(impl, network)
      @impl, @network = impl, network
    end

    def post(uri, body, original_headers = {}, &block)
      headers = {
        "oauth_consumer_key" => network.consumer_key || "",
        "oauth_token"        => network.auth_token,
      }.update(original_headers)
      oauth_params = {
        "body" => body,
        "oauth_signature_method" => "HMAC-SHA1"
      }.update(headers)

      req_hash = {
        "method" => "POST",
        "uri"    => uri,
        "parameters" => oauth_params
      }

      headers["oauth_signature"] = OAuth::Signature.sign(
        req_hash,
        :consumer_secret => network.consumer_secret,
        :token_secret    => network.signature_key)
      res = @impl.post(uri, body, headers)
    end
  end
end
