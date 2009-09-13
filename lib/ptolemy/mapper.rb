class MapperError < Exception; end

module Ptolemy

  class Mapper
    
    class << self
      attr_reader :direction, :current_map_definition_key

      def [](key)
        definitions[key.to_sym]
      end 

      def define(key, &block)
        raise MapperError, "A mapping for the key #{key} currently exists.  Are you sure you want to merge the mapping you are about to do with the existing mapping?" if definitions.keys.include?(key)

        definitions[key.to_sym] ||= DefinitionMapper.new(key)
        definitions[key.to_sym].instance_eval(&block)
      end 
      
      def load(str)
        instance_eval(str.strip)
      end 

      def definitions
        @definitions ||= {}
      end
      
      def namespace(namespace, &block)
        namespaces[namespace.to_sym] ||= NamespaceMapper.new(name)
        namespaces[namespace.to_sym].instance_eval(&block)
      end 

      def namespaces
        @namespaces ||= {}
      end

      def reset
        @map_definitions = nil
      end

      def translate(key=nil, source=nil)
        raise MapperError, "No target mapper exists for key #{key}" unless definitions.has_key?(key)
        
        definitions[key].translate(source)
      end

    end
  end

  module Definable

    def method_missing(method, *args)
      if(current_map_definition.respond_to?(method))
        current_map_definition.send(method, *args)
      else
        super
      end 
    end 

  end 

  class DefinitionMapper
    attr_reader :name, :definition
    include Definable

    def initialize(name)
      @name = name
    end 

    def current_map_definition
      @definition ||= MapDefinition.new
    end

  end 

  class NamespaceMapper
    attr_reader :name, :map_definitions
    include Definable

    def initialize(name)
      @name = name
    end 

    def define(key, &block)
      raise MapperError, "A mapping for the key #{key} currently exists.  Are you sure you want to merge the mapping you are about to do with the existing mapping?" if definitions.keys.include?(key)

      @current_map_definition_key = key
      yield current_map_definition
    end

    private

    def current_map_definition
      definitions[@current_map_definition_key] ||= MapDefinition.new
    end

    def definitions
      @map_definitions ||= {}
    end

  end
end
