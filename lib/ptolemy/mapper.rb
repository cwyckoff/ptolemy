class MapperError < Exception; end

module Ptolemy

  class Mapper
    
    class << self
      attr_reader :current_map_definition_key
      attr_accessor :map_directory

      def [](key)
        definitions[key.to_sym]
      end 

      def define(key, &block)
        raise MapperError, "A mapping for the key #{key} currently exists.  Are you sure you want to merge the mapping you are about to do with the existing mapping?" if definitions.keys.include?(key)

        definitions[key.to_sym] ||= DefinitionMapper.new(key)
        definitions[key.to_sym].instance_eval(&block)
      end 

      def definitions
        @definitions ||= {}
      end

      def load_maps
        path = File.join(map_directory, "*.rb")
        raise LoadError, "No maps defined for map directory #{map_directory}.  Please save your mapping files to a map directory and let Ptolemy know about it (e.g., Ptolemy::Mapper.map_directory = '/foo/bar')" unless Dir.glob(path).size > 0

        Dir.glob(path).each do |map|
          load_str(File.read(map))
        end
      end 
      
      def load_str(str)
        instance_eval(str.strip)
      end 

      def namespace(namespace, &block)
        namespaces[namespace.to_sym] ||= NamespaceMapper.new(namespace)
        namespaces[namespace.to_sym].instance_eval(&block)
      end 

      def namespaces
        @namespaces ||= {}
      end

      def reset
        @definitions, @namespaces = nil, nil
      end

      def translate(key, source)
        raise MapperError, "No target mapper exists for key #{key}" unless definitions.has_key?(key)
        
        definitions[key].translate(source)
      end

      def translate_namespace(namespace, key, source)
        raise MapperError, "No target mapper exists for key #{key}" unless namespaces.has_key?(namespace)
        
        namespaces[namespace].translate(key, source)
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
      @name = name.to_s
    end 

    def current_map_definition
      @definition ||= MapDefinition.new
    end

  end 

  class NamespaceMapper
    attr_reader :name, :map_definitions
    include Definable

    def initialize(name)
      @name = name.to_s
    end 

    def define(key, &block)
      raise MapperError, "A mapping for the key #{key} currently exists.  Are you sure you want to merge the mapping you are about to do with the existing mapping?" if definitions.keys.include?(key)

      @current_map_definition_key = key.to_sym
      yield current_map_definition
    end

    def translate(key, source)
      definitions[key.to_sym].translate(source)
    end

    def current_map_definition
      definitions[@current_map_definition_key] ||= MapDefinition.new
    end

    def definitions
      @map_definitions ||= {}
    end

  end
end
