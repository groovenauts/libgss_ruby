# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'libgss'
require 'tengine/support/yaml_with_erb'

require 'fontana_client_support'
require 'mongoid'


Mongoid.logger.level = 0
log_path = File.expand_path("../../tmp/test.log", __FILE__)
FileUtils.mkdir_p(File.dirname(log_path))
logger = Logger.new(log_path)
logger.level = Logger::DEBUG
Mongoid.logger = logger


Mongoid.load!(File.expand_path("../../fontana_sample/config/fontana_mongoid.yml", __FILE__), :development)

require 'active_support/dependencies'

Time.zone = ActiveSupport::TimeZone.zones_map["Tokyo"]

# require File.expand_path("../../fontana_sample/spec/spec_helper", __FILE__)

d = File.expand_path("../support/models", __FILE__)
"Directory not found: #{d.inspect}" unless Dir.exist?(d)
ActiveSupport::Dependencies.autoload_paths << d

Dir[File.expand_path("../support/auto/**/*.rb", __FILE__)].each {|f| require f}


require 'factory_girl'
FactoryGirl.find_definitions

RSpec.configure do |config|
  # iOS開発環境が整っていない場合、SSLで接続する https://sandbox.itunes.apple.com/verifyreceipt が
  # オレオレ証明書を使っているので、その検証をができなくてエラーになってしまいます。
  # 本来ならば、信頼する証明書として追加する方が良いと思われますが、
  # ( http://d.hatena.ne.jp/komiyak/20130508/1367993536 )
  # 証明書自身の検証はローカルの開発環境で行うことができるので、ここでは単純に検証をスキップする
  # ように設定してしまいます。
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  config.include FactoryGirl::Syntax::Methods
end

