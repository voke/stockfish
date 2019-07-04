module Stockfish
  class Function

    attr_accessor :name, :body, :dependencies

    def initialize(name, body, dependencies)
      self.name = name.to_sym
      if self.name.eql?(:all)
        raise(ArgumentError, ':all is not valid function name')
      end
      self.body = body
      self.dependencies = Array(dependencies).flatten
      validate_naming_convention!
    end

    def validate_naming_convention!
      real_name = self.body.strip.scan(/^def ([a-zA-z0-9]+)/).join
      if real_name != name.to_s
        msg = 'Avoid mismatch between name and actual function name.'
        raise msg + " '#{real_name}' != '#{name}'"
      end
    end

    def to_filter
      self.body
    end

  end
end
