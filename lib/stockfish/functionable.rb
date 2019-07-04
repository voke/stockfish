require 'set'

module Stockfish
  module Functionable

    def functions_filter
      self.class.jq_functions_chain.map(&:to_filter)
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def define_function(name, body = nil, depends_on: [])
        body = block_given? ? yield : body
        func = Stockfish::Function.new(name, body, depends_on)
        jq_functions[func.name] = func
      end

      def load_function(name, path)
        if File.extname(path) != '.jq'
          raise(ArgumentError, 'File must have extension .jq')
        end
        File.open(path) do |file|
          define_function(name, file.read)
        end
      end

      def resolve_dependencies(func)
        deps = func.dependencies.map { |dep| resolve_dependencies(load_lazy_function(dep)) }
        deps + [func]
      end

      def jq_functions_chain
        stack = Set.new
        selected_functions.merge(jq_functions).values.each do |func|
          stack.merge(resolve_dependencies(func).flatten)
        end
        stack
      end

      def inherited_functions
        ancestors.map do |klass|
          klass.jq_functions if klass.respond_to?(:jq_functions)
        end.compact.flatten
      end

      def load_lazy_function(name)
        lazy_functions[name] || raise(Stockfish::MissingFunctionError, "Missing function: '#{name}'")
      end

      # Functions defined in subclasses
      def lazy_functions
        inherited_functions.inject(&:merge)
      end

      def all_dependencies
        ancestors.reverse.map do |klass|
          klass.dependencies if klass.respond_to?(:dependencies)
        end.compact.inject(&:merge)
      end

      def selected_functions
        all_dependencies.reduce({}) do |h, k|
          if !lazy_functions.has_key?(k)
            raise(Stockfish::MissingFunctionError, "Missing function: '#{k}'")
          end
          h[k] = lazy_functions[k]
          h
        end
      end

      def depends_on(*function_names)
        function_names.each do |name|
          dependencies.add(name.to_sym)
        end
      end

      def dependencies
        @dependencies ||= Set.new
      end

      def jq_functions
        @jq_functions ||= {}
      end

    end

  end
end
