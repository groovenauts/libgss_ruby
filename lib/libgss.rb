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

  class Error < StandardError; end
  class ClientError < Error; end

  class ErrorResponse < Error
    class << self
      def subclasses
        @subclasses ||= []
      end
      def inherited(klass)
        subclasses << klass
      end
      def build(res)
        return nil if res.nil?
        klass = subclasses.detect{|k| k.respond_to?(:match?) && k.match?(res)} || self
        klass.new(res.status, res.content)
      end
    end

    attr_reader :status
    def initialize(status, message)
      @status = status
      super(message)
    end
  end

  class InvalidResponse < ErrorResponse
  end

  class ServerBlockError < ErrorResponse
    STATUS = 503
    BODY = "api maintenance".freeze
    def self.match?(res)
      res.content.nil? ? false :
        (res.status == STATUS) && (res.content.strip == BODY)
    end
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
