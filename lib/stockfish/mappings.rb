
# Helper class to handle mappings.
# Input format should be:
# If path starts with a period it will be treated as raw/advanced
#
# {
#   image_link: 'images.image.location',
#   price: '.price | tonumber / 100'
# }
#

module Stockfish
  class Mappings < DelegateClass(Hash)

    class MappingPath < DelegateClass(String)

      def initialize(path)
        raise(ArgumentError, 'Path must be a String') unless path.is_a?(String)
        super(path)
      end

      # Apply text() filter to grab "$text" if object.
      def simple_path
        "#{serialize_path} | text"
      end

      # If the key contains special characters, you need to surround
      # it with double quotes like this: .["foo$"]
      # Ignore paths with whitespace or starts/ends with a period
      def serialize_path
        keys = index(/\s/) || end_with?('.') || start_with?('.') ? [self] : split('.')
        keys.map do |part|
          '["%s"]' % part
        end.join.insert(0, '.')
      end

      def to_filter
        start_with?('.', '[') ? self : simple_path
      end

    end

    def initialize(hash)
      hash = Hash[hash.map do |name, path|
        [name, MappingPath.new(path)]
      end]
      super(hash)
    end

    # Returns a command like { name: .path.to['$name'] }
    def to_filter
      inner = map do |name, path|
        "\s\s#{name}: (#{path.to_filter})"
      end.join(",\n")
      "{\n#{inner}\n}"
    end

  end
end
