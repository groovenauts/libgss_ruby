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
end
