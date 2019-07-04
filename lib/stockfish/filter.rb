module Stockfish
  class Filter < DelegateClass(String)

    def initialize(body)
      super(body)
    end

    def compile(subject)
      gsub(/\{\{([a-z0-9_.]+)\}\}/) do |match|
        subject.dig(*match[2..-3].split('.'))
      end
    end

  end
end
