require 'yaml'
require 'tengine/support/yaml_with_erb'

module AppGarden
  CONFIG_PATH = File.expand_path("../../../../fontana_sample/config/app_garden.yml", __FILE__)

  module_function

  def config
    @config ||= YAML.load_file(CONFIG_PATH)
  end
end
