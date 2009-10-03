class MapDefinitionError < Exception; end

module Ptolemy

  class MapDefinition
    attr_reader :rules, :dir
    
    def initialize
      @rules = []
    end

    def direction(dir)
      raise MapDefinitionError, "Direction must be a hash" unless dir.is_a?(Hash)

      @dir = dir
    end
    
    def unless(condition=nil, &block)
      @rules.last.target.register_condition(:unless, condition, &block)
      self
    end
    
    def when(condition=nil, &block)
      @rules.last.target.register_condition(:when, condition, &block)
    end
    
    def customize(&block)
      @rules.last.target.register_customized(&block)
    end
    
    def from(from_str)
      raise MapDefinitionError, "Please specify a source mapping" if from_str.nil?
      source = MapFactory.source(@dir, {from_str => ''})

      @rules << MapRule.new(source)
      self
    end

    def include(map_definition=nil, opts={})
      raise MapDefinitionError, "A mapping definition key is required (e.g., m.include(:another_map))" if map_definition.nil?
      raise MapDefinitionError, "Mapping definition for #{map_definition} does not exist" unless (other_mapper = included_mapper(map_definition))

      other_mapper.rules.each do |m|
        source = m.source.dup
        target = m.target.dup

        if opts[:inside_of]
          source.path_translator.unshift(opts[:inside_of])
          target.path_translator.unshift(opts[:inside_of])
        end 

        @rules << MapRule.new(source, target)
      end 
      self
    end

    def map(opts={})
      raise MapDefinitionError, "Both key and value pair must be set (e.g., {\"foo/bar\" => \"bar/foo\")" if (opts.empty?)
      
      @rules << MapRule.new(MapFactory.source(@dir, opts), MapFactory.target(@dir, opts))
      self
    end
    
    def prepopulate(target_data)
      source_proxy = SourceProxy.new
      @rules << MapRule.new(source_proxy, MapFactory.target(@dir, {:to => target_data}))
      source_proxy
    end

    def reset
      @rules, @dir = [], nil
    end

    def to(&block)
      raise MapDefinitionError, "You must call the .from method before customizing the .to method (e.g., m.from(\"foo\").to {|value| ...}" unless @rules.last

      target = MapFactory.target(@dir, {:to => '', :to_proc => block})
      @rules.last.target = target
      self
    end
    
    def translate(source)
      target = nil
      @rules.each do |rule|
        target = rule.initial_target if target.nil?
        filtered_source = rule.filtered_source(source) if filtered_source.nil?
        
        source_value = rule.source_value(filtered_source)
        rule.translate(target, source_value)
      end
      target
    end

    def reverse(source)
      target = nil
      @rules.each do |rule|
        target = rule.source.class.initial_target if target.nil?
        filtered_source = rule.target.class.filter_source(source) if filtered_source.nil?
        
        source_value = rule.target.value_from(filtered_source)
        rule.reverse(target, source_value)
      end
      target
    end

    private

    def included_mapper(map_definition)
      elements = map_definition.to_s.split("::")
      if(elements.size > 1)
        definition = elements.pop
        namespace = nil
        elements.each { |namespace| namespace = Mapper[namespace]}
        namespace.definitions[definition.to_sym]
      else 
        Mapper.definitions[map_definition.to_sym]
      end 
    end 

  end
end
