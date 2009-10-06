module Ptolemy

  class ToolsError < Exception; end

  class Tools
    
    class << self
      attr_accessor :mapping_path

      def compare(source_key, target_key)
        puts "Comparing source map definition: '#{source_key.to_s}' with target map definition: '#{target_key.to_s}'\n\n"
        source_paths = definition(source_key).rules.map { |r| r.source_path }
        target_paths = definition(target_key).rules.map { |r| r.target_path }
        
        max_length = source_paths.map { |path| path.length }.max
        source_paths.each_with_index do |s_path, index|
          yield max_length, s_path, target_paths[index]
        end 
      end

      def keys
        Ptolemy::Mapper.definitions.each do |key, definition|
          puts "#{key}\n"
        end
      end 

      def list_definition(key)
        length = max_source_path_length(definition(key))
        definition(key).rules.each do |rule|
          yield length, rule.source_path, rule.target_path
        end 
      end

      def list_sources(key)
        definition(key).rules.each do |rule|
          yield rule.source_path
        end 
      end

      def list_targets(key)
        definition(key).rules.each do |rule|
          yield rule.target_path
        end 
      end

      def translate(definition, source_path, source)
        rule = definition(definition).rules.detect {|rule| rule.source_path == source_path.to_s}
        source_value = rule.source_value(rule.filtered_source(source))
        target = rule.initial_target
        rule.translate(target, source_value)
        target
      end 

      private

      def definition(key)
        elements = key.to_s.split(":")
        if(elements.size > 1)
          definition = elements.pop
          namespace = nil
          elements.each { |namespace| namespace = Mapper[namespace.to_sym] }
          namespace.definitions[definition.to_sym]
        else 
          Ptolemy::Mapper.definitions[key.to_sym]
        end 
      end 

      def max_source_path_length(definition)
        definition.rules.map { |r| r.source_path.length }.max
      end 
      
    end 
  end 
end 
