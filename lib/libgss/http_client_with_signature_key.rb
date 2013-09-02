# -*- coding: utf-8 -*-
require 'libgss'

require 'oauth'

require 'digest/hmac'

require 'uri'

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
      }
      oauth_params = {
        "body" => body,
        "oauth_signature_method" => "HMAC-SHA1"
      }.update(headers)

      req_hash = {
        "method" => "POST",
        "uri"    => uri,
        "parameters" => oauth_params
      }

      options = {
        :consumer_secret => network.consumer_secret,
        :token_secret    => network.signature_key
      }

      signature_class = Libgss.use_oauth_gem ? ::OAuth::Signature : Signature
      $stdout.puts("signature_class: #{signature_class.name}") if ENV["VERBOSE"]

      headers["oauth_signature"] = signature_class.sign(req_hash, options)

      res = @impl.post(uri, body, headers.update(original_headers))
    end

    def get(uri, query={}, original_headers = {}, &block)
      headers = {
        "oauth_consumer_key" => network.consumer_key || "",
        "oauth_token"        => network.auth_token,
      }
      oauth_params = {
        "oauth_signature_method" => "HMAC-SHA1"
      }.update(headers)

      encoded_query = ''
      query.each do |key, val|
        key = key.to_s
        if val.is_a?(::Array)
          k = CGI.escape("#{key}[]")
          val.each do |v|
            encoded_query << "&#{k}=#{URI.escape(v.to_s)}"
          end
        elsif val.is_a?(::Hash)
          val.each do |k, v|
            k = URI.escape("#{key}[#{k}]")
            encoded_query << "&#{k}=#{URI.escape(v.to_s)}"
          end
        else
          encoded_query << "&#{URI.escape(key)}=#{URI.escape(val.to_s)}"
        end
      end
      if uri =~ /\?/
        uri += encoded_query
      else
        uri += encoded_query.gsub(/^&/, '?')
      end
      req_hash = {
        "method" => "POST",
        "uri"    => uri,
        "parameters" => oauth_params
      }
      puts(req_hash.inspect)

      options = {
        :consumer_secret => network.consumer_secret,
        :token_secret    => network.signature_key
      }

      signature_class = Libgss.use_oauth_gem ? ::OAuth::Signature : Signature
      $stdout.puts("signature_class: #{signature_class.name}") if ENV["VERBOSE"]

      headers["oauth_signature"] = signature_class.sign(req_hash, options)

      res = @impl.get(uri, nil, headers.update(original_headers))
    end

    class Signature
      class << self
        def sign(req_hash, options)
          new(req_hash, options).sign
        end
      end

      def initialize(req_hash, options)
        @request, @options = req_hash, options
      end

      def sign
        s = digest          # ダイジェストを計算
        Base64.encode64(s). # BASE64でエンコード
          chomp.        # 末尾から改行コード(\r or \n)を取り除いた文字列を返す
          gsub(/\n/,'') # 改行を全て取り除く
      end

      def digest
        s = signature_base_string # base_stringを計算
        digest_class = ::Digest::SHA1 # http://doc.ruby-lang.org/ja/1.9.3/class/Digest=3a=3aSHA1.html

        # digest_class.digest(s) # Digestクラスを使って計算

        # http://doc.ruby-lang.org/ja/1.9.3/library/digest=2fhmac.html
        # http://doc.ruby-lang.org/ja/1.9.3/class/Digest=3a=3aHMAC.html
        ::Digest::HMAC.digest(s, secret, digest_class)
      end

      def signature_base_string
        base = [
          @request["method"],
          normalized_uri,
          normalized_parameters]
        base.map { |v| escape(v) }.join("&")
      end

      def normalized_uri
        u = URI.parse(@request["uri"])
        "#{u.scheme.downcase}://#{u.host.downcase}#{(u.scheme.downcase == 'http' && u.port != 80) || (u.scheme.downcase == 'https' && u.port != 443) ? ":#{u.port}" : ""}#{(u.path && u.path != '') ? u.path : '/'}"
      rescue
        @request["uri"]
      end

      def normalized_parameters
        normalize(parameters_for_signature)
      end

      def parameters_for_signature
        parameters.reject { |k,v| k == "oauth_signature"}
      end

      def parameters
        @request["parameters"]
      end


      def secret
        "#{escape(@options[:consumer_secret])}&#{escape(@options[:token_secret])}"
      end


      RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

      def escape(value)
        URI::escape(value.to_s, RESERVED_CHARACTERS)
      rescue ArgumentError
        URI::escape(value.to_s.force_encoding(Encoding::UTF_8), RESERVED_CHARACTERS)
      end

      def normalize(params)
        params.sort.map do |k, values|

          if values.is_a?(Array)
            # multiple values were provided for a single key
            values.sort.collect do |v|
              [escape(k),escape(v)] * "="
            end
          else
            [escape(k),escape(values)] * "="
          end
        end * "&"
      end

    end

  end
end
