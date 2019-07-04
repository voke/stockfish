module Stockfish
  class Filter < DelegateClass(String)

    def initialize(body)
      super(body)
    end

    def compile(subject)
      gsub(/\{\{(\w*)\}\}/) { |match| subject[match[2..-3]] }
    end

  end
end
