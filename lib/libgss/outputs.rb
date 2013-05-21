# -*- coding: utf-8 -*-
require 'libgss'

require 'forwardable'

module Libgss

  class Outputs
    extend Forwardable
    include Enumerable

    def initialize(array)
      @array = array
    end

    # メソッドを@arrayに移譲する
    def_delegators :@array, :[], :length, :first, :last, :inspect, :each

    def get(id)
      @array.detect{|output| output["id"] == id}
    end
  end
end
