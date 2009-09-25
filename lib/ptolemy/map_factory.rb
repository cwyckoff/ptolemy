module Ptolemy

  class MapFactory
    
    def self.source(direction, opts={})
      Ptolemy.const_get("#{pop(direction, :keys).to_s.capitalize}Map").new(PathTranslator.new(pop(opts, :keys)), opts)
    end

    def self.target(direction, opts={})
      Ptolemy.const_get("#{pop(direction, :values).to_s.capitalize}Map").new(PathTranslator.new(pop(opts, :values)), opts)
    end

    private

    def self.pop(hash, side)
      hash.send(side.to_sym).pop
    end 

  end 


  class SourceProxy

    attr_reader :path_translator

    def initialize
      @path_translator = PathTranslator.new("/")
    end 

    def self.filter_source(source)
      source
    end

    def value_from(source=nil)
      @source_value
    end 

    def with(value)
      @source_value = value
    end 

  end 

end

