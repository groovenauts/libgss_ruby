# -*- coding: utf-8 -*-
require 'libgss'

require 'forwardable'

module Libgss

  class Outputs
    extend Forwardable

    def initialize(array)
      @array = array
    end

    # メソッドを@arrayに移譲する
    def_delegators :@array, :[], :length, :first, :last

    def get(id)
      @array.detect{|output| output["id"] == id}
    end

  end
end
