module Parsers
  class Base
    attr_reader :fields

    def initialize(text)
      @fields = text.to_s.split(',')
    end

    def parse
      raise 'should be redefined!'
    end
  end
end
