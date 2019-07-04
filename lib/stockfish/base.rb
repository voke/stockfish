module Stockfish
  class Base

    include Functionable

    # Stockfish only defines one function by default, and that's text()
    # used for mappings.
    depends_on :text
    define_function :text do
      'def text: if type == "object" then .["$text"] else . end;'
    end

    def initialize(custom_mappings: {}, options: {}, additional_filters: [])
      @custom_mappings = custom_mappings.transform_keys(&:to_sym)
      @options = options
      @additional_filters = additional_filters
    end

    def self.identifier
      name_without_namespace = name.split("::").last
      name_without_namespace.gsub(/([^\^])([A-Z])/,'\1-\2').downcase.to_sym
    end

    def self.before_filter(snippet = nil)
      before_filters.push(Stockfish::Filter.new(snippet ? snippet : yield))
    end

    def self.after_filter(snippet = nil)
      after_filters.push(Stockfish::Filter.new(snippet ? snippet : yield))
    end

    def self.before_filters
      @before_filters ||= []
    end

    def self.after_filters
      @after_filters ||= []
    end

    def self.before_fitlers_chain
      (superclass.before_filters + before_filters)
    end

    def self.after_filters_chain
      (after_filters + superclass.after_filters)
    end

    def self.jq_functions
      @jq_functions ||= {}
    end

    def self.default_mappings
      self::DEFAULT_MAPPINGS
    end

    def final_mappings
      Stockfish::Mappings.new(self.class.default_mappings.merge(@custom_mappings).reject do |_, path|
        path.nil? || path.empty?
      end)
    end

    def jq_filter
      before_filters = self.class.before_fitlers_chain.map { |f| f.compile(@options) }.join(' | ')
      after_filters = self.class.after_filters_chain.map { |f| f.compile(@options) }.join(' | ')
      functions_filter.join + ([before_filters, map_filter, after_filters,
        @additional_filters.join(' | ')].reject(&:empty?).join(' | '))
    end

    # Returns a command like { name: .path.to['$name'] }
    # Apply text() filter to grab "$text" if object.
    def map_filter
      final_mappings.to_filter
    end

  end
end
