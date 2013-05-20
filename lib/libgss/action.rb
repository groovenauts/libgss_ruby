# -*- coding: utf-8 -*-
require 'libgss'

module Libgss

  class Action

    attr_accessor :id

    def initialize(id, args)
      @id = id
      @args = args
    end

    def with(new_id)
      @id = new_id
      self
    end

    def to_hash
      {"id" => id}.update(@args)
    end

  end
end
