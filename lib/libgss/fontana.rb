# -*- coding: utf-8 -*-
require 'libgss'

module Libgss
  module Fontana

    class << self
      # これは fontanaの Fontana.env と同じ動きをすることが期待されています。
      # https://github.com/tengine/fontana/blob/master/config/application.rb#L24
      def env
        @env ||= (ENV["FONTANA_ENV"] || "DEVELOPMENT").to_sym
      end
    end

  end
end
