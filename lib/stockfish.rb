require 'stockfish/version'
require 'stockfish/function'
require 'stockfish/filter'
require 'stockfish/mappings'
require 'stockfish/functionable'
require 'stockfish/base'

module Stockfish

  Error = Class.new(StandardError)
  MissingFunctionError = Class.new(Error)

end
