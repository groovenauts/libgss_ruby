require "libgss/version"

module Libgss

  autoload :Network      , "libgss/network"
  autoload :Action       , "libgss/action"
  autoload :ActionRequest, "libgss/action_request"
  autoload :AsyncActionRequest, "libgss/async_action_request"
  autoload :Outputs      , "libgss/outputs"
  autoload :HttpClientWithSignatureKey, "libgss/http_client_with_signature_key"

  autoload :AssetRequest , "libgss/asset_request"
  autoload :Fontana      , "libgss/fontana"

  class << self
    attr_accessor :use_oauth_gem
  end

  self.use_oauth_gem = (ENV["USE_OAUTH_GEM"] =~ /\Atrue\Z|\Aon\Z/i)

  MAX_RETRY_COUNT = (ENV["LIBGSS_MAX_RETRY_COUNT"] || 10).to_i

  class Error < StandardError
  end

  class << self

    def with_retry(name)
      retry_count = 0
      begin
        return yield
      rescue OpenSSL::SSL::SSLError => e
        $stderr.puts("retrying #{name} [#{e.class.name}] #{e.message}")
        sleep(0.2)
        retry_count += 1
        retry if retry_count <= MAX_RETRY_COUNT
        raise e
      end
    end

  end
end
